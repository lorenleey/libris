/* ==============================================================
   LIBRIS - 04: vistas y funciones
   Se puede ejecutar varias veces (CREATE OR ALTER).
   ============================================================== */
USE Libris;
GO

-- REGEXP_LIKE (y el resto de funciones REGEXP_*) necesita nivel de
-- compatibilidad 170 (SQL Server 2025). Una base nueva suele nacer
-- con 170; esto lo asegura.
IF (SELECT compatibility_level FROM sys.databases WHERE name = N'Libris') < 170
    ALTER DATABASE Libris SET COMPATIBILITY_LEVEL = 170;
GO

-- ---------------------------------------------------------------
-- VIEW 1: catálogo con autores y géneros agrupados
-- (usa subconsultas correlacionadas y STRING_AGG)
-- ---------------------------------------------------------------
CREATE OR ALTER VIEW dbo.vw_BookCatalog
AS
SELECT b.BookId,
       b.Title,
       (SELECT STRING_AGG(a.FullName, N', ') WITHIN GROUP (ORDER BY a.FullName)
        FROM dbo.BookAuthors ba
        JOIN dbo.Authors a ON a.AuthorId = ba.AuthorId
        WHERE ba.BookId = b.BookId) AS Authors,
       (SELECT STRING_AGG(g.Name, N', ') WITHIN GROUP (ORDER BY g.Name)
        FROM dbo.BookGenres bg
        JOIN dbo.Genres g ON g.GenreId = bg.GenreId
        WHERE bg.BookId = b.BookId) AS Genres,
       b.PublishedYear,
       b.IsAvailable,
       b.Synopsis
FROM dbo.Books b;
GO

-- ---------------------------------------------------------------
-- VIEW 2: valoración media y número de valoraciones por libro
-- (los libros sin valoraciones salen con AverageScore NULL)
-- ---------------------------------------------------------------
CREATE OR ALTER VIEW dbo.vw_BookRatings
AS
SELECT b.BookId,
       b.Title,
       COUNT(r.RatingId) AS RatingCount,
       CAST(AVG(CAST(r.Score AS DECIMAL(4,2))) AS DECIMAL(3,2)) AS AverageScore
FROM dbo.Books b
LEFT JOIN dbo.Ratings r ON r.BookId = b.BookId
GROUP BY b.BookId, b.Title;
GO

-- ---------------------------------------------------------------
-- FUNCTION 1 (escalar): valoración media de un libro
-- ---------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_AverageRating (@BookId INT)
RETURNS DECIMAL(3,2)
AS
BEGIN
    RETURN (SELECT CAST(AVG(CAST(Score AS DECIMAL(4,2))) AS DECIMAL(3,2))
            FROM dbo.Ratings
            WHERE BookId = @BookId);
END;
GO

-- ---------------------------------------------------------------
-- FUNCTION 2 (inline, devuelve tabla): libros de un socio con su
-- estado y su valoración. Servirá para la personalización.
-- ---------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_MemberBooks (@MemberId INT)
RETURNS TABLE
AS
RETURN
(
    SELECT l.BookId,
           b.Title,
           l.Status,
           l.LoanDate,
           r.Score
    FROM dbo.Loans l
    JOIN dbo.Books b ON b.BookId = l.BookId
    LEFT JOIN dbo.Ratings r ON r.BookId = l.BookId AND r.MemberId = l.MemberId
    WHERE l.MemberId = @MemberId
);
GO
