/* ==============================================================
   LIBRIS - 03: datos de prueba (tamaño mínimo)
   15 libros, 13 autores, 7 géneros, 4 socios, 14 préstamos y
   12 valoraciones. Los ISBN son ficticios (solo de ejemplo).
   Las relaciones se hacen por nombre, no por ID, para que el
   script no dependa del orden de los IDENTITY.
   Inserta solo datos que faltan; conserva registros ya existentes.
   Ejecutar en una sola sesión, sin otras cargas simultáneas.
   ============================================================== */
USE Libris;
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
BEGIN TRANSACTION;

-- ---------------------------------------------------------------
-- Géneros y autores
-- ---------------------------------------------------------------
INSERT INTO dbo.Genres (Name)
SELECT v.Name
FROM (VALUES (N'Ciencia ficción'), (N'Fantasía'), (N'Misterio'), (N'Novela histórica'),
       (N'Distopía'), (N'Clásico'), (N'Aventura')) AS v(Name)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Genres AS existing
    WHERE existing.Name = v.Name
);

INSERT INTO dbo.Authors (FullName)
SELECT v.FullName
FROM (VALUES (N'Frank Herbert'), (N'Isaac Asimov'), (N'Ursula K. Le Guin'), (N'William Gibson'),
       (N'George Orwell'), (N'Ray Bradbury'), (N'Umberto Eco'), (N'Agatha Christie'),
       (N'Stieg Larsson'), (N'J. R. R. Tolkien'), (N'Gabriel García Márquez'),
       (N'Miguel de Cervantes'), (N'Carlos Ruiz Zafón')) AS v(FullName)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Authors AS existing
    WHERE existing.FullName = v.FullName
);

-- ---------------------------------------------------------------
-- Libros (sinopsis redactadas con palabras propias)
-- ---------------------------------------------------------------
INSERT INTO dbo.Books (Title, Isbn, Synopsis, PublishedYear)
SELECT v.Title, v.Isbn, v.Synopsis, v.PublishedYear
FROM (VALUES
(N'Dune', '9780000000001',
 N'Un joven noble debe sobrevivir en el planeta desértico Arrakis, donde se disputa la especia más valiosa del universo en una guerra de familias, política y religión.', 1965),
(N'Fundación', '9780000000002',
 N'Un matemático predice la caída de un imperio galáctico y crea una fundación para acortar los siglos de oscuridad que vendrán.', 1951),
(N'Yo, robot', '9780000000003',
 N'Relatos sobre la convivencia entre humanos y robots regidos por tres leyes, y los dilemas que surgen cuando esas leyes entran en conflicto.', 1950),
(N'La mano izquierda de la oscuridad', '9780000000004',
 N'Un enviado terrestre llega a un planeta helado cuyos habitantes no tienen sexo fijo y debe lograr una alianza política en medio de la desconfianza.', 1969),
(N'Neuromante', '9780000000005',
 N'Un hacker caído en desgracia es contratado para una última misión en el ciberespacio, entre corporaciones, inteligencias artificiales y mercenarios.', 1984),
(N'1984', '9780000000006',
 N'En un estado totalitario que lo vigila todo, un empleado del gobierno empieza a rebelarse contra la manipulación de la verdad y del pasado.', 1949),
(N'Fahrenheit 451', '9780000000007',
 N'En una sociedad donde los libros están prohibidos, un bombero encargado de quemarlos empieza a cuestionar su trabajo.', 1953),
(N'El nombre de la rosa', '9780000000008',
 N'Un monje franciscano investiga una serie de muertes misteriosas en una abadía medieval cuya biblioteca esconde un secreto peligroso.', 1980),
(N'Asesinato en el Orient Express', '9780000000009',
 N'Un detective debe resolver un crimen cometido en un tren detenido por la nieve, donde todos los pasajeros tienen algo que ocultar.', 1934),
(N'Los hombres que no amaban a las mujeres', '9780000000010',
 N'Un periodista y una joven hacker investigan la desaparición de una mujer décadas atrás en una poderosa familia sueca.', 2005),
(N'El Hobbit', '9780000000011',
 N'Un hobbit tranquilo se une a un grupo de enanos y a un mago en un viaje para recuperar un tesoro custodiado por un dragón.', 1937),
(N'Un mago de Terramar', '9780000000012',
 N'Un joven aprendiz de mago libera por error una sombra oscura y debe enfrentarse a ella en un archipiélago de islas y mares.', 1968),
(N'Cien años de soledad', '9780000000013',
 N'La historia de varias generaciones de la familia Buendía en el pueblo imaginario de Macondo, entre amores, guerras y hechos mágicos.', 1967),
(N'Don Quijote de la Mancha', '9780000000014',
 N'Un hidalgo enloquecido por los libros de caballerías sale a recorrer España junto a su escudero para vivir aventuras heroicas.', 1605),
(N'La sombra del viento', '9780000000015',
 N'En la Barcelona de posguerra, un niño descubre un libro olvidado y se adentra en el misterio de su autor desaparecido.', 2001)) AS v(Title, Isbn, Synopsis, PublishedYear)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Books AS existing
    WHERE existing.Isbn = v.Isbn
);

-- ---------------------------------------------------------------
-- Relaciones libro-autor y libro-género (por nombre)
-- ---------------------------------------------------------------
INSERT INTO dbo.BookAuthors (BookId, AuthorId)
SELECT b.BookId, a.AuthorId
FROM (VALUES
    (N'Dune', N'Frank Herbert'),
    (N'Fundación', N'Isaac Asimov'),
    (N'Yo, robot', N'Isaac Asimov'),
    (N'La mano izquierda de la oscuridad', N'Ursula K. Le Guin'),
    (N'Neuromante', N'William Gibson'),
    (N'1984', N'George Orwell'),
    (N'Fahrenheit 451', N'Ray Bradbury'),
    (N'El nombre de la rosa', N'Umberto Eco'),
    (N'Asesinato en el Orient Express', N'Agatha Christie'),
    (N'Los hombres que no amaban a las mujeres', N'Stieg Larsson'),
    (N'El Hobbit', N'J. R. R. Tolkien'),
    (N'Un mago de Terramar', N'Ursula K. Le Guin'),
    (N'Cien años de soledad', N'Gabriel García Márquez'),
    (N'Don Quijote de la Mancha', N'Miguel de Cervantes'),
    (N'La sombra del viento', N'Carlos Ruiz Zafón')
) AS v(Title, Author)
JOIN dbo.Books   b ON b.Title    = v.Title
JOIN dbo.Authors a ON a.FullName = v.Author
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.BookAuthors AS existing
    WHERE existing.BookId = b.BookId AND existing.AuthorId = a.AuthorId
);

INSERT INTO dbo.BookGenres (BookId, GenreId)
SELECT b.BookId, g.GenreId
FROM (VALUES
    (N'Dune', N'Ciencia ficción'),        (N'Dune', N'Aventura'),
    (N'Fundación', N'Ciencia ficción'),
    (N'Yo, robot', N'Ciencia ficción'),
    (N'La mano izquierda de la oscuridad', N'Ciencia ficción'),
    (N'Neuromante', N'Ciencia ficción'),
    (N'1984', N'Distopía'),               (N'1984', N'Clásico'),
    (N'Fahrenheit 451', N'Distopía'),     (N'Fahrenheit 451', N'Ciencia ficción'),
    (N'El nombre de la rosa', N'Misterio'), (N'El nombre de la rosa', N'Novela histórica'),
    (N'Asesinato en el Orient Express', N'Misterio'), (N'Asesinato en el Orient Express', N'Clásico'),
    (N'Los hombres que no amaban a las mujeres', N'Misterio'),
    (N'El Hobbit', N'Fantasía'),          (N'El Hobbit', N'Aventura'),
    (N'Un mago de Terramar', N'Fantasía'),
    (N'Cien años de soledad', N'Clásico'),
    (N'Don Quijote de la Mancha', N'Clásico'), (N'Don Quijote de la Mancha', N'Aventura'),
    (N'La sombra del viento', N'Misterio'), (N'La sombra del viento', N'Novela histórica')
) AS v(Title, Genre)
JOIN dbo.Books  b ON b.Title = v.Title
JOIN dbo.Genres g ON g.Name  = v.Genre
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.BookGenres AS existing
    WHERE existing.BookId = b.BookId AND existing.GenreId = g.GenreId
);

-- ---------------------------------------------------------------
-- Socios (LoginName será el usuario de BD en la fase de seguridad)
-- ---------------------------------------------------------------
INSERT INTO dbo.Members (FullName, Email, LoginName)
SELECT v.FullName, v.Email, v.LoginName
FROM (VALUES (N'Ana López',   N'ana@example.com',   N'ana'),
       (N'Bruno Martín', N'bruno@example.com', N'bruno'),
       (N'Carla Ruiz',  N'carla@example.com',  N'carla'),
       (N'David Soto',  N'david@example.com',  N'david')) AS v(FullName, Email, LoginName)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Members AS existing
    WHERE existing.LoginName = v.LoginName
);

-- ---------------------------------------------------------------
-- Préstamos: cada socio tiene un gusto distinto
--   Ana: ciencia ficción | Bruno: misterio | Carla: fantasía | David: clásicos
-- ---------------------------------------------------------------
INSERT INTO dbo.Loans (BookId, MemberId, LoanDate, ReturnDate, Status)
SELECT b.BookId, m.MemberId, v.LoanDate, v.ReturnDate, v.Status
FROM (VALUES
    (N'Ana López',    N'Dune',                              '2026-06-02', '2026-06-20', 'Terminado'),
    (N'Ana López',    N'Fundación',                         '2026-07-01', '2026-07-18', 'Terminado'),
    (N'Ana López',    N'Neuromante',                        '2026-08-05', '2026-08-25', 'Terminado'),
    (N'Ana López',    N'Yo, robot',                         '2026-09-20', NULL,         'Prestado'),
    (N'Bruno Martín', N'El nombre de la rosa',              '2026-06-10', '2026-06-30', 'Terminado'),
    (N'Bruno Martín', N'Asesinato en el Orient Express',    '2026-07-12', '2026-07-20', 'Terminado'),
    (N'Bruno Martín', N'La sombra del viento',              '2026-08-01', '2026-08-22', 'Terminado'),
    (N'Bruno Martín', N'Los hombres que no amaban a las mujeres', '2026-09-25', NULL,   'Prestado'),
    (N'Carla Ruiz',   N'El Hobbit',                         '2026-06-05', '2026-06-15', 'Terminado'),
    (N'Carla Ruiz',   N'Un mago de Terramar',               '2026-07-03', '2026-07-14', 'Terminado'),
    (N'Carla Ruiz',   N'Cien años de soledad',              '2026-08-10', '2026-09-01', 'Terminado'),
    (N'David Soto',   N'Don Quijote de la Mancha',          '2026-06-15', '2026-07-10', 'Terminado'),
    (N'David Soto',   N'Cien años de soledad',              '2026-07-15', '2026-08-05', 'Terminado'),
    (N'David Soto',   N'Fahrenheit 451',                    '2026-08-20', '2026-08-28', 'Terminado')
) AS v(Member, Title, LoanDate, ReturnDate, Status)
JOIN dbo.Members m ON m.FullName = v.Member
JOIN dbo.Books   b ON b.Title    = v.Title
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Loans AS existing
    WHERE existing.BookId = b.BookId AND existing.MemberId = m.MemberId
      AND existing.LoanDate = CONVERT(date, v.LoanDate)
);

-- Recalcular la disponibilidad a partir del estado actual de los préstamos.
UPDATE b
SET IsAvailable = CASE WHEN EXISTS (
    SELECT 1 FROM dbo.Loans AS l
    WHERE l.BookId = b.BookId AND l.Status = 'Prestado'
) THEN 0 ELSE 1 END
FROM dbo.Books AS b;

-- ---------------------------------------------------------------
-- Valoraciones (solo de libros terminados; incluye una baja)
-- ---------------------------------------------------------------
INSERT INTO dbo.Ratings (BookId, MemberId, Score)
SELECT b.BookId, m.MemberId, v.Score
FROM (VALUES
    (N'Ana López',    N'Dune',                           5),
    (N'Ana López',    N'Fundación',                      5),
    (N'Ana López',    N'Neuromante',                     4),
    (N'Bruno Martín', N'El nombre de la rosa',           5),
    (N'Bruno Martín', N'Asesinato en el Orient Express', 4),
    (N'Bruno Martín', N'La sombra del viento',           5),
    (N'Carla Ruiz',   N'El Hobbit',                      5),
    (N'Carla Ruiz',   N'Un mago de Terramar',            5),
    (N'Carla Ruiz',   N'Cien años de soledad',           4),
    (N'David Soto',   N'Don Quijote de la Mancha',       2),
    (N'David Soto',   N'Cien años de soledad',           5),
    (N'David Soto',   N'Fahrenheit 451',                 4)
) AS v(Member, Title, Score)
JOIN dbo.Members m ON m.FullName = v.Member
JOIN dbo.Books   b ON b.Title    = v.Title
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Ratings AS existing
    WHERE existing.BookId = b.BookId AND existing.MemberId = m.MemberId
);

COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- ---------------------------------------------------------------
-- Comprobación rápida de filas
-- Esperado: Books 15, Authors 13, Genres 7, BookAuthors 15,
--           BookGenres 23, Members 4, Loans 14, Ratings 12
-- ---------------------------------------------------------------
SELECT 'Books' AS tabla, COUNT(*) AS filas FROM dbo.Books
UNION ALL SELECT 'Authors',     COUNT(*) FROM dbo.Authors
UNION ALL SELECT 'Genres',      COUNT(*) FROM dbo.Genres
UNION ALL SELECT 'BookAuthors', COUNT(*) FROM dbo.BookAuthors
UNION ALL SELECT 'BookGenres',  COUNT(*) FROM dbo.BookGenres
UNION ALL SELECT 'Members',     COUNT(*) FROM dbo.Members
UNION ALL SELECT 'Loans',       COUNT(*) FROM dbo.Loans
UNION ALL SELECT 'Ratings',     COUNT(*) FROM dbo.Ratings
UNION ALL SELECT 'SearchHistory', COUNT(*) FROM dbo.SearchHistory;
GO
