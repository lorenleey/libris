/* ==============================================================
   LIBRIS - Pruebas de la Fase 3 (T-SQL y objetos de programación)
   Ejecuta cada sección por separado y guarda una captura del
   resultado. Requiere haber ejecutado 01 a 05.
   ============================================================== */
USE Libris;
GO

-- ===============================================================
-- 0. Comprobar que los objetos existen
-- ===============================================================
SELECT name, type_desc
FROM sys.objects
WHERE name IN (N'vw_BookCatalog', N'vw_BookRatings', N'fn_AverageRating',
               N'fn_MemberBooks', N'usp_RegisterLoan', N'usp_ReturnLoan',
               N'trg_Loans_UpdateAvailability')
ORDER BY type_desc, name;
-- Esperado: 7 filas (2 vistas, 2 funciones, 2 procedimientos, 1 trigger)
GO

-- ===============================================================
-- 1. Vistas
-- ===============================================================
SELECT BookId, Title, Authors, Genres, IsAvailable
FROM dbo.vw_BookCatalog
ORDER BY Title;

SELECT Title, RatingCount, AverageScore
FROM dbo.vw_BookRatings
ORDER BY AverageScore DESC, Title;
-- Esperado: Cien años de soledad con 4.50 (dos valoraciones: 4 y 5)
GO

-- ===============================================================
-- 2. Funciones
-- ===============================================================
SELECT Title, dbo.fn_AverageRating(BookId) AS MediaFuncion
FROM dbo.Books
ORDER BY MediaFuncion DESC, Title;

SELECT * FROM dbo.fn_MemberBooks((SELECT MemberId FROM dbo.Members WHERE LoginName = N'ana'));
-- Esperado: los 4 libros de Ana (Yo, robot sin valoración y en estado Prestado)
GO

-- ===============================================================
-- 3. Procedimientos y trigger (prestar, error controlado, devolver)
--    Todo en un solo bloque; al final se borra el préstamo de prueba
--    para dejar los datos como estaban.
-- ===============================================================

IF @@TRANCOUNT <> 0
    THROW 50010, N'Ejecuta la prueba sin una transacción abierta.', 1;

DECLARE @bookId   INT = (SELECT BookId  
                         FROM dbo.Books  
                          WHERE Title     = N'Dune');

DECLARE @memberId INT = (SELECT MemberId 
                        FROM dbo.Members 
                        WHERE LoginName = N'bruno');

DECLARE @loanId INT = NULL;
DECLARE @secondLoanId INT = NULL;
DECLARE @expectedError BIT = 0;

IF @bookId IS NULL OR @memberId IS NULL
    THROW 50011, N'Faltan los datos de prueba: Dune o Bruno.', 1;

IF NOT EXISTS (
    SELECT 1 FROM dbo.Books
    WHERE BookId = @bookId AND IsAvailable = 1
)
OR EXISTS (
    SELECT 1 FROM dbo.Loans
    WHERE BookId = @bookId AND Status = 'Prestado'
)
    THROW 50012, N'Dune debe estar disponible antes de la prueba.', 1;

BEGIN TRY
    SELECT Title, IsAvailable AS Disponible_antes 
    FROM dbo.Books 
    WHERE BookId = @bookId;            -- 1

    -- crear el préstamo y recibir su ID
    EXEC dbo.usp_RegisterLoan 
    @MemberId = @memberId, 
    @BookId = @bookId,
    @LoanId = @loanId OUTPUT;

    IF @loanId IS NULL
        THROW 50013, N'El procedimiento no devolvió el ID.', 1;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.Books
        WHERE BookId = @bookId AND IsAvailable = 0
    )
        THROW 50014, N'El trigger no marcó el libro como ocupado.', 1;

    SELECT @loanId AS PrestamoCreado,
           Title,
           IsAvailable AS Disponible_tras_prestar
    FROM dbo.Books
    WHERE BookId = @bookId;

-- Segundo intento: debe fallar con el error 50002
BEGIN TRY
    EXEC dbo.usp_RegisterLoan 
    @MemberId = @memberId, 
    @BookId = @bookId,
    @LoanId = @secondLoanId OUTPUT;
END TRY
BEGIN CATCH
 IF ERROR_NUMBER() <> 50002
            THROW;

        SET @expectedError = 1;

        SELECT ERROR_NUMBER() AS Numero,
               ERROR_MESSAGE() AS Mensaje;
END CATCH;

    IF @expectedError = 0
        THROW 50015, N'El segundo préstamo debería haber fallado.', 1;


-- Devolver exactamente el préstamo creado.
    EXEC dbo.usp_ReturnLoan @LoanId = @loanId;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.Loans
        WHERE LoanId = @loanId
          AND Status = 'Terminado'
          AND ReturnDate IS NOT NULL
    )
        THROW 50016, N'El préstamo no se ha devuelto correctamente.', 1;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.Books
        WHERE BookId = @bookId AND IsAvailable = 1
    )
        THROW 50017, N'El trigger no ha liberado el libro.', 1;

    SELECT Title, IsAvailable AS Disponible_tras_devolver
    FROM dbo.Books
    WHERE BookId = @bookId;

    -- El DELETE también dispara el trigger.
    DELETE FROM dbo.Loans
    WHERE LoanId = @loanId;

    SELECT N'Prueba correcta; préstamo de prueba eliminado.'
           AS Resultado;
END TRY

-- Limpieza (el DELETE también activa el trigger)
BEGIN CATCH
    DELETE FROM dbo.Loans 
    WHERE LoanId = @loanId;

    THROW;
END CATCH;
GO

-- ===============================================================
-- 4. T-SQL avanzado
-- ===============================================================

-- 4.1 CTE + window functions: ranking de libros dentro de cada género
WITH GenreScores AS
(
    SELECT g.Name AS Genre, r.Title, r.AverageScore
    FROM dbo.vw_BookRatings r
    JOIN dbo.BookGenres bg ON bg.BookId  = r.BookId
    JOIN dbo.Genres     g  ON g.GenreId  = bg.GenreId
    WHERE r.AverageScore IS NOT NULL
)
SELECT Genre,
       Title,
       AverageScore,
       RANK()       OVER (PARTITION BY Genre ORDER BY AverageScore DESC)        AS PosicionEnGenero,
       ROW_NUMBER() OVER (PARTITION BY Genre ORDER BY AverageScore DESC, Title) AS Fila
FROM GenreScores
ORDER BY Genre, PosicionEnGenero, Title;
GO

-- 4.2 Window functions: favoritos de cada socio frente a su propia media
SELECT m.FullName,
       b.Title,
       r.Score,
       CAST(AVG(CAST(r.Score AS DECIMAL(4,2))) OVER (PARTITION BY r.MemberId) AS DECIMAL(3,2)) AS MediaDelSocio,
       DENSE_RANK() OVER (PARTITION BY r.MemberId ORDER BY r.Score DESC)                       AS FavoritoNumero
FROM dbo.Ratings r
JOIN dbo.Members m ON m.MemberId = r.MemberId
JOIN dbo.Books   b ON b.BookId   = r.BookId
ORDER BY m.FullName, FavoritoNumero, b.Title;
GO

-- 4.3 Consulta correlacionada: valoraciones por encima de la media del propio socio
SELECT m.FullName, b.Title, r.Score
FROM dbo.Ratings r
JOIN dbo.Members m ON m.MemberId = r.MemberId
JOIN dbo.Books   b ON b.BookId   = r.BookId
WHERE r.Score > (SELECT AVG(CAST(r2.Score AS DECIMAL(4,2)))
                 FROM dbo.Ratings r2
                 WHERE r2.MemberId = r.MemberId)
ORDER BY m.FullName, r.Score DESC;
GO

-- 4.4 JSON: generar un libro con autores y géneros y leerlo de vuelta
DECLARE @json NVARCHAR(MAX) =
(
    SELECT b.Title,
           b.PublishedYear,
           (SELECT a.FullName AS Name
            FROM dbo.BookAuthors ba
            JOIN dbo.Authors a ON a.AuthorId = ba.AuthorId
            WHERE ba.BookId = b.BookId
            FOR JSON PATH) AS Authors,
           (SELECT g.Name AS Name
            FROM dbo.BookGenres bg
            JOIN dbo.Genres g ON g.GenreId = bg.GenreId
            WHERE bg.BookId = b.BookId
            FOR JSON PATH) AS Genres
    FROM dbo.Books b
    WHERE b.Title = N'Dune'
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
);

SELECT @json AS LibroEnJson;

SELECT JSON_VALUE(@json, '$.Title')           AS Titulo,
       JSON_VALUE(@json, '$.Authors[0].Name') AS PrimerAutor;

SELECT g.Name AS Genero
FROM OPENJSON(@json, '$.Genres') WITH (Name NVARCHAR(50) '$.Name') AS g;
GO

-- 4.5 Expresión regular: validar el formato de un ISBN-13
--     (REGEXP_LIKE exige nivel de compatibilidad 170)
SELECT v.Isbn,
       CASE WHEN REGEXP_LIKE(v.Isbn, '^(978|979)[0-9]{10}$')
            THEN N'Formato válido'
            ELSE N'Formato inválido'
       END AS Resultado
FROM (VALUES ('9780000000001'),
             ('978-0-00-000000-1'),
             ('12345'),
             ('9790000000009')) AS v(Isbn);
-- Esperado: válido, inválido, inválido, válido
GO

-- 4.6 Fuzzy string matching: encontrar un autor escrito con errata
--     Es una función en PREVIEW en SQL Server 2025: hay que activarla.
--     Las funciones fuzzy no admiten collations SQL_* no binarias, por eso
--     se fuerza una collation Windows con COLLATE (también ignora acentos).
ALTER DATABASE SCOPED CONFIGURATION SET PREVIEW_FEATURES = ON;
GO

DECLARE @buscado NVARCHAR(100) = N'Isac Asimov';   -- errata intencionada

SELECT TOP (3)
       a.FullName,
       EDIT_DISTANCE_SIMILARITY(a.FullName COLLATE Latin1_General_100_CI_AI,
                                @buscado   COLLATE Latin1_General_100_CI_AI) AS SimilitudEdicion,
       JARO_WINKLER_SIMILARITY(a.FullName COLLATE Latin1_General_100_CI_AI,
                               @buscado   COLLATE Latin1_General_100_CI_AI) AS SimilitudJaroWinkler
FROM dbo.Authors a
ORDER BY SimilitudEdicion DESC;
-- Esperado: Isaac Asimov en primer lugar con similitud alta
GO
