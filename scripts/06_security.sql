/* ==============================================================
   LIBRIS - 06: seguridad
   Mecanismos implementados:
     1. Usuarios, roles y permisos (GRANT / DENY / REVOKE)
     2. Row-Level Security (RLS) sobre Loans y Ratings
     3. Dynamic Data Masking (DDM) sobre Members.Email

   Idea del modelo:
     - rol_socio : consulta el catálogo, ve SOLO sus propios préstamos
                   y puede valorar libros solo con su propio MemberId.
     - rol_admin : bibliotecario, ve y gestiona todo y ve los emails.
   Los préstamos son privados; las valoraciones son públicas (así
   la media de cada libro cuenta con las valoraciones de todos).

   Se puede ejecutar varias veces. Si necesitas volver a ejecutar
   02_create_tables.sql, ejecuta antes 06_security_remove.sql.
   ============================================================== */
USE Libris;
GO

-- ---------------------------------------------------------------
-- 0. Esquema para los objetos de seguridad
-- ---------------------------------------------------------------
IF SCHEMA_ID(N'Security') IS NULL
    EXEC (N'CREATE SCHEMA Security');
GO

-- ---------------------------------------------------------------
-- 1. Roles y usuarios de demostración
--    WITHOUT LOGIN: no necesitan inicio de sesión del servidor;
--    se usan con EXECUTE AS USER en las pruebas.
--    Los nombres coinciden con Members.LoginName.
-- ---------------------------------------------------------------
IF DATABASE_PRINCIPAL_ID(N'rol_admin') IS NULL CREATE ROLE rol_admin;
IF DATABASE_PRINCIPAL_ID(N'rol_socio') IS NULL CREATE ROLE rol_socio;

IF DATABASE_PRINCIPAL_ID(N'ana')         IS NULL CREATE USER ana         WITHOUT LOGIN;
IF DATABASE_PRINCIPAL_ID(N'bruno')       IS NULL CREATE USER bruno       WITHOUT LOGIN;
IF DATABASE_PRINCIPAL_ID(N'carla')       IS NULL CREATE USER carla       WITHOUT LOGIN;
IF DATABASE_PRINCIPAL_ID(N'david')       IS NULL CREATE USER david       WITHOUT LOGIN;
IF DATABASE_PRINCIPAL_ID(N'admin_libris') IS NULL CREATE USER admin_libris WITHOUT LOGIN;

ALTER ROLE rol_socio ADD MEMBER ana;
ALTER ROLE rol_socio ADD MEMBER bruno;
ALTER ROLE rol_socio ADD MEMBER carla;
ALTER ROLE rol_socio ADD MEMBER david;
ALTER ROLE rol_admin ADD MEMBER admin_libris;
GO

-- ---------------------------------------------------------------
-- 2. Dynamic Data Masking: el email se muestra enmascarado a quien
--    no tenga el permiso UNMASK (p. ej. aXXX@XXXX.com)
-- ---------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.masked_columns
               WHERE object_id = OBJECT_ID(N'dbo.Members') AND name = N'Email')
    ALTER TABLE dbo.Members
        ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()');
GO

-- ---------------------------------------------------------------
-- 3. Vista "mi perfil": cada socio ve solo su fila de Members.
--    Así no hace falta darles acceso directo a la tabla (la vista
--    y la tabla tienen el mismo propietario, por lo que se
--    aplica el encadenamiento de propiedad). El administrador ve
--    todas las filas.
-- ---------------------------------------------------------------
CREATE OR ALTER VIEW dbo.vw_MyProfile
AS
SELECT MemberId, FullName, Email, LoginName, JoinDate
FROM dbo.Members
WHERE LoginName = USER_NAME()
   OR IS_MEMBER(N'rol_admin') = 1
   OR IS_MEMBER(N'db_owner') = 1;
GO

-- ---------------------------------------------------------------
-- 4. Permisos (principio de mínimo privilegio)
-- ---------------------------------------------------------------
-- Administrador: todo el esquema dbo y ver los datos sin máscara
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::dbo TO rol_admin;
GRANT UNMASK TO rol_admin;

-- Socio: lectura del catálogo y de su información
GRANT SELECT ON dbo.Books         TO rol_socio;
GRANT SELECT ON dbo.Authors       TO rol_socio;
GRANT SELECT ON dbo.Genres        TO rol_socio;
GRANT SELECT ON dbo.BookAuthors   TO rol_socio;
GRANT SELECT ON dbo.BookGenres    TO rol_socio;
GRANT SELECT ON dbo.Ratings       TO rol_socio;
GRANT SELECT ON dbo.Loans         TO rol_socio;      -- RLS: solo verá los suyos
GRANT SELECT ON dbo.vw_BookCatalog TO rol_socio;
GRANT SELECT ON dbo.vw_BookRatings TO rol_socio;
GRANT SELECT ON dbo.vw_MyProfile   TO rol_socio;
GRANT SELECT ON dbo.fn_MemberBooks TO rol_socio;     -- función que devuelve tabla
GRANT EXECUTE ON dbo.fn_AverageRating TO rol_socio;  -- función escalar
GRANT INSERT ON dbo.Ratings       TO rol_socio;      -- valorar libros (con block predicate)

-- DENY explícito: tiene prioridad sobre cualquier GRANT
DENY INSERT, UPDATE, DELETE ON dbo.Books   TO rol_socio;
DENY INSERT, UPDATE, DELETE ON dbo.Loans   TO rol_socio;
DENY UPDATE, DELETE         ON dbo.Ratings TO rol_socio;
DENY SELECT                 ON dbo.Members TO rol_socio;   -- solo vía vw_MyProfile
GO

-- ---------------------------------------------------------------
-- 5. Row-Level Security
--    Función predicado: devuelve una fila (=permitido) si el usuario
--    es administrador/propietario, o si el MemberId de la fila
--    pertenece al usuario actual (Members.LoginName = USER_NAME()).
--    Con SCHEMABINDING (obligatorio aquí) la consulta a Members
--    dentro de la función no requiere permisos extra al socio.
-- ---------------------------------------------------------------


-- En mi caso el SCHEMA Security no existía, si esto sucede se debe consultar la existencia de la siguiente manera 
--
-- SELECT name FROM sys.schemas WHERE name = N'Security'; 
--
--

-- De no dar ningún resultado, proceder a la creación 
--
--CREATE SCHEMA Security;
-- GO
IF EXISTS (SELECT 1 FROM sys.security_policies WHERE name = N'LibrisPolicy')
    DROP SECURITY POLICY Security.LibrisPolicy;
GO

DROP FUNCTION IF EXISTS Security.fn_MemberRowAccess;
GO

CREATE FUNCTION Security.fn_MemberRowAccess (@MemberId INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS fn_result
    WHERE USER_NAME() = N'dbo'
       OR IS_MEMBER(N'db_owner') = 1
       OR IS_MEMBER(N'rol_admin') = 1
       OR EXISTS (SELECT 1
                  FROM dbo.Members m
                  WHERE m.MemberId  = @MemberId
                    AND m.LoginName = USER_NAME());
GO

-- FILTER: cada socio solo ve sus préstamos
-- BLOCK AFTER INSERT: nadie puede insertar una valoración a nombre de otro socio
CREATE SECURITY POLICY Security.LibrisPolicy
    ADD FILTER PREDICATE Security.fn_MemberRowAccess(MemberId) ON dbo.Loans,
    ADD BLOCK  PREDICATE Security.fn_MemberRowAccess(MemberId) ON dbo.Ratings AFTER INSERT
WITH (STATE = ON);
GO
