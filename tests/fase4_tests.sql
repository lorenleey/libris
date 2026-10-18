/* ==============================================================
   LIBRIS - Pruebas de la Fase 4 (seguridad)
   Ejecuta cada sección por separado

   Se usa EXECUTE AS USER para comportarse como cada usuario.
   Cada bloque termina con REVERT. Si algo falla a mitad y notas
   que sigues "siendo" otro usuario, ejecuta:  REVERT;
   ============================================================== */
USE Libris;
GO

-- ===============================================================
-- 0. Estado de la seguridad
-- ===============================================================
SELECT r.name AS Rol, 
        m.name AS Miembro
FROM sys.database_role_members rm
JOIN sys.database_principals r 
ON r.principal_id = rm.role_principal_id
JOIN sys.database_principals m 
ON m.principal_id = rm.member_principal_id
WHERE r.name IN (N'rol_admin', N'rol_socio')
ORDER BY r.name, m.name;
-- Esperado: rol_admin -> admin_libris ; rol_socio -> ana, bruno, carla, david

SELECT name AS Politica, 
        is_enabled 
FROM sys.security_policies;
-- Esperado: LibrisPolicy con is_enabled = 1

SELECT OBJECT_NAME(object_id) AS Tabla, 
        name AS Columna, masking_function
FROM sys.masked_columns;
-- Esperado: Members.Email con email()
GO

-- ===============================================================
-- 1. Ana (socio): solo ve sus préstamos y su perfil
-- ===============================================================
DECLARE @brunoId INT = (SELECT MemberId 
                        FROM dbo.Members 
                        WHERE LoginName = N'bruno');

EXECUTE AS USER = N'ana';

SELECT USER_NAME() AS UsuarioActual;

SELECT l.LoanId, 
        b.Title, 
        l.Status
FROM dbo.Loans l
JOIN dbo.Books b 
ON b.BookId = l.BookId
ORDER BY l.LoanId;
-- Esperado: 4 filas (los préstamos de Ana)

SELECT FullName, 
        Email, 
        LoginName
 FROM dbo.vw_MyProfile;
-- Esperado: solo Ana, con el email enmascarado (aXXX@XXXX.com)

DECLARE @anaId INT = (SELECT MemberId 
                        FROM dbo.vw_MyProfile);
SELECT COUNT(*) AS MisLibros        
FROM dbo.fn_MemberBooks(@anaId);     -- 4
SELECT COUNT(*) AS LibrosDeBruno    
FROM dbo.fn_MemberBooks(@brunoId);   -- 0 (RLS)

REVERT;
GO

-- ===============================================================
-- 2. Bruno (socio): ve únicamente los suyos
-- ===============================================================
EXECUTE AS USER = N'bruno';

SELECT USER_NAME() AS UsuarioActual;
SELECT COUNT(*) AS PrestamosVisibles FROM dbo.Loans;   -- 4 (los de Bruno)

REVERT;
GO

-- ===============================================================
-- 3. Administrador: ve todo y los emails sin máscara
-- ===============================================================
EXECUTE AS USER = N'admin_libris';

SELECT USER_NAME() AS UsuarioActual;

SELECT COUNT(*) AS PrestamosVisibles 
FROM dbo.Loans;   -- 14

SELECT FullName, Email 
FROM dbo.vw_MyProfile;          -- 4 socios, emails completos

REVERT;
GO

-- ===============================================================
-- 4. Propietario (dbo, tú): también ve todo
-- ===============================================================
SELECT USER_NAME() AS UsuarioActual, 
        COUNT(*) AS PrestamosVisibles 
FROM dbo.Loans;   -- 14
GO

-- ===============================================================
-- 5. DENY y mínimo privilegio: lo que un socio NO puede hacer
-- ===============================================================
EXECUTE AS USER = N'ana';

BEGIN TRY
    UPDATE dbo.Books SET IsAvailable = 0 
    WHERE Title = N'Dune';
    SELECT N'ERROR: no debería poder modificar el catálogo' AS Resultado;
END TRY
BEGIN CATCH
    SELECT N'UPDATE en Books' AS Intento, 
    ERROR_NUMBER() AS Numero, 
    ERROR_MESSAGE() AS Mensaje;
END CATCH;

BEGIN TRY
    DELETE FROM dbo.Loans;
    SELECT N'ERROR: no debería poder borrar préstamos' AS Resultado;
END TRY
BEGIN CATCH
    SELECT N'DELETE en Loans' AS Intento, 
    ERROR_NUMBER() AS Numero, 
    ERROR_MESSAGE() AS Mensaje;
END CATCH;

BEGIN TRY
    SELECT * 
    FROM dbo.Members;
    SELECT N'ERROR: no debería leer la tabla Members' AS Resultado;
END TRY
BEGIN CATCH
    SELECT N'SELECT en Members' AS Intento, 
    ERROR_NUMBER() AS Numero, 
    ERROR_MESSAGE() AS Mensaje;
END CATCH;

REVERT;
-- Esperado: tres errores de permiso denegado (número 229)
GO

-- ===============================================================
-- 6. Block predicate: valorar solo con tu propio MemberId
-- ===============================================================
DECLARE @brunoId INT = (SELECT MemberId 
                        FROM dbo.Members 
                        WHERE LoginName = N'bruno');
DECLARE @bookId  INT = (SELECT BookId   
                        FROM dbo.Books 
                        WHERE Title     = N'Fahrenheit 451');

EXECUTE AS USER = N'ana';

-- (a) Valoración propia: permitida
BEGIN TRY
    INSERT INTO dbo.Ratings (BookId, MemberId, Score)
    SELECT @bookId, MemberId, 4 
    FROM dbo.vw_MyProfile;
    SELECT N'OK: Ana ha valorado con su propio MemberId' AS Resultado;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS Numero, 
    ERROR_MESSAGE() AS Mensaje;
END CATCH;

-- (b) Valoración a nombre de Bruno: bloqueada
BEGIN TRY
    INSERT INTO dbo.Ratings (BookId, MemberId, Score)
    VALUES (@bookId, @brunoId, 1);
    SELECT N'ERROR: no debería poder valorar como otro socio' AS Resultado;
END TRY
BEGIN CATCH
    SELECT N'Valoración como Bruno' AS Intento, 
    ERROR_NUMBER() AS Numero, 
    ERROR_MESSAGE() AS Mensaje;
END CATCH;

REVERT;

-- Limpieza (como dbo): se borra la valoración de prueba de Ana
DELETE FROM dbo.Ratings
WHERE BookId = @bookId
  AND MemberId = (SELECT MemberId FROM dbo.Members WHERE LoginName = N'ana');
-- Esperado: (a) OK y (b) error de block predicate
GO

-- ===============================================================
-- 7. GRANT y REVOKE: conceder y retirar un permiso
-- ===============================================================
GRANT SELECT ON dbo.SearchHistory TO rol_socio;

EXECUTE AS USER = N'ana';
SELECT COUNT(*) AS FilasVisibles_conGRANT 
FROM dbo.SearchHistory;   -- funciona (0 filas)
REVERT;

REVOKE SELECT ON dbo.SearchHistory 
FROM rol_socio;

EXECUTE AS USER = N'ana';
BEGIN TRY
    SELECT COUNT(*) AS FilasVisibles 
    FROM dbo.SearchHistory;
    SELECT N'ERROR: el REVOKE no ha surtido efecto' AS Resultado;
END TRY
BEGIN CATCH
    SELECT N'SELECT tras REVOKE' AS Intento, 
    ERROR_NUMBER() AS Numero, 
    ERROR_MESSAGE() AS Mensaje;
END CATCH;
REVERT;
GO

-- ===============================================================
-- 8. Efecto de RLS: política desactivada y activada
--    Si algo falla entre el OFF y el ON, ejecuta el ON manualmente.
-- ===============================================================
ALTER SECURITY POLICY Security.LibrisPolicy WITH (STATE = OFF);

EXECUTE AS USER = N'ana';
SELECT COUNT(*) AS PrestamosVisibles_RLS_OFF FROM dbo.Loans;   -- 14
REVERT;

ALTER SECURITY POLICY Security.LibrisPolicy WITH (STATE = ON);

EXECUTE AS USER = N'ana';
SELECT COUNT(*) AS PrestamosVisibles_RLS_ON FROM dbo.Loans;    -- 4
REVERT;
GO
