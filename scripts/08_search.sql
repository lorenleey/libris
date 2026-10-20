/* ==============================================================
   LIBRIS - 08: motor de búsqueda y personalización
   Requisitos: scripts 01 a 05, embeddings generados
   (ai/01_generate_embeddings.sql), Ollama y Caddy en marcha, y
   para las búsquedas de texto/híbrida el índice de 07_fulltext.sql.
   Se puede ejecutar varias veces (CREATE OR ALTER).

   Contenido:
     fn_MemberAffinity        afinidad de un socio con cada libro
     usp_SearchBooksSemantic  búsqueda por significado (VECTOR)
     usp_RecommendForMember   recomendaciones a partir del historial
     usp_SearchBooksText      búsqueda tradicional (Full-Text)
     usp_SearchBooksHybrid    texto + vector (+ perfil) con RRF

   RRF (Reciprocal Rank Fusion): cada lista de resultados aporta
   1 / (60 + posición). Se combinan POSICIONES, no valores, porque
   la distancia vectorial y el ranking de Full-Text no están en la
   misma escala y no se pueden sumar.
   ============================================================== */
USE Libris;
GO

-- ---------------------------------------------------------------
-- FUNCIÓN: afinidad de un socio con los libros que aún no ha leído
--   Cada libro del historial (prestado o valorado) es una "semilla"
--   con un peso:
--     sin valorar = 1 | valoración 3 = 1 | 4 = 2 | 5 = 3 | 1-2 = -2
--   Afinidad = media ponderada de la similitud coseno con las
--   semillas (1 - distancia). Una semilla con peso negativo resta.
--   También devuelve la semilla más parecida ("porque te gustó X").
-- ---------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_MemberAffinity (@MemberId INT)
RETURNS TABLE
AS
RETURN
(
    WITH Seeds AS
    (
        SELECT l.BookId,
               MAX(CASE WHEN r.Score IS NULL THEN 1
                        WHEN r.Score = 5     THEN 3
                        WHEN r.Score = 4     THEN 2
                        WHEN r.Score = 3     THEN 1
                        ELSE -2 END) AS Weight
        FROM dbo.Loans l
        LEFT JOIN dbo.Ratings r
               ON r.BookId = l.BookId AND r.MemberId = l.MemberId
        WHERE l.MemberId = @MemberId
        GROUP BY l.BookId
    ),
    Scored AS
    (
        SELECT b.BookId,
               SUM(s.Weight * (1.0 - VECTOR_DISTANCE('cosine', b.Embedding, sb.Embedding)))
                 / NULLIF(SUM(ABS(s.Weight)), 0) AS AffinityScore
        FROM dbo.Books b
        CROSS JOIN Seeds s
        JOIN dbo.Books sb ON sb.BookId = s.BookId
        WHERE b.Embedding  IS NOT NULL
          AND sb.Embedding IS NOT NULL
          AND b.BookId NOT IN (SELECT BookId FROM Seeds)   -- excluir lo ya leído
        GROUP BY b.BookId
    )
    SELECT sc.BookId,
           sc.AffinityScore,
           basis.SeedTitle
    FROM Scored sc
    JOIN dbo.Books bb ON bb.BookId = sc.BookId
    OUTER APPLY
    (
        SELECT TOP (1) sb.Title AS SeedTitle
        FROM Seeds s
        JOIN dbo.Books sb ON sb.BookId = s.BookId
        WHERE s.Weight > 0 AND sb.Embedding IS NOT NULL
        ORDER BY VECTOR_DISTANCE('cosine', bb.Embedding, sb.Embedding)
    ) AS basis
);
GO

-- ---------------------------------------------------------------
-- PROCEDURE: búsqueda semántica (por significado)
-- ---------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.usp_SearchBooksSemantic
    @Query    NVARCHAR(300),
    @Top      INT = 5,
    @MemberId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Embedding de la pregunta con el mismo modelo que los libros
    DECLARE @q VECTOR(1024) = AI_GENERATE_EMBEDDINGS(@Query USE MODEL OllamaBgeM3);

    IF @q IS NULL
        THROW 50020, N'No se pudo generar el embedding de la consulta (¿Ollama o Caddy cerrados?).', 1;

    INSERT INTO dbo.SearchHistory (MemberId, QueryText, SearchType)
    VALUES (@MemberId, @Query, 'vectorial');

    SELECT TOP (@Top)
           c.BookId,
           c.Title,
           c.Authors,
           c.Genres,
           CAST(VECTOR_DISTANCE('cosine', b.Embedding, @q) AS DECIMAL(6,4)) AS DistanciaCoseno
    FROM dbo.Books b
    JOIN dbo.vw_BookCatalog c ON c.BookId = b.BookId
    WHERE b.Embedding IS NOT NULL
    ORDER BY VECTOR_DISTANCE('cosine', b.Embedding, @q);   -- menor distancia = más parecido
END;
GO

-- ---------------------------------------------------------------
-- PROCEDURE: recomendaciones a partir del historial del socio
-- ---------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.usp_RecommendForMember
    @MemberId INT,
    @Top      INT = 5
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Members WHERE MemberId = @MemberId)
        THROW 50004, N'El socio no existe.', 1;

    SELECT TOP (@Top)
           c.BookId,
           c.Title,
           c.Authors,
           c.Genres,
           CAST(a.AffinityScore AS DECIMAL(6,4)) AS Afinidad,
           a.SeedTitle                           AS BasadoEn
    FROM dbo.fn_MemberAffinity(@MemberId) a
    JOIN dbo.vw_BookCatalog c ON c.BookId = a.BookId
    ORDER BY a.AffinityScore DESC, c.Title;
END;
GO

-- ---------------------------------------------------------------
-- PROCEDURE: búsqueda tradicional (Full-Text, por palabras)
-- Requiere el índice de 07_fulltext.sql
-- ---------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.usp_SearchBooksText
    @Query    NVARCHAR(300),
    @Top      INT = 5,
    @MemberId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.SearchHistory (MemberId, QueryText, SearchType)
    VALUES (@MemberId, @Query, 'texto');

    SELECT TOP (@Top)
           c.BookId,
           c.Title,
           c.Authors,
           c.Genres,
           ft.[RANK] AS RankTexto
    FROM FREETEXTTABLE(dbo.Books, (Title, Synopsis), @Query, LANGUAGE 3082) AS ft
    JOIN dbo.vw_BookCatalog c ON c.BookId = ft.[KEY]
    ORDER BY ft.[RANK] DESC, c.Title;
END;
GO

-- ---------------------------------------------------------------
-- PROCEDURE: búsqueda híbrida con RRF
--   Sin @MemberId: combina texto + vector.
--   Con @MemberId: añade una tercera lista, la afinidad con el
--   historial del socio (búsqueda personalizada).
--   @ExcludeRead = 1 oculta los libros que el socio ya tiene en su historial.
-- Requiere el índice de 07_fulltext.sql
-- ---------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.usp_SearchBooksHybrid
    @Query       NVARCHAR(300),
    @MemberId    INT = NULL,
    @Top         INT = 5,
    @ExcludeRead BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @q VECTOR(1024) = AI_GENERATE_EMBEDDINGS(@Query USE MODEL OllamaBgeM3);

    IF @q IS NULL
        THROW 50020, N'No se pudo generar el embedding de la consulta (¿Ollama o Caddy cerrados?).', 1;

    INSERT INTO dbo.SearchHistory (MemberId, QueryText, SearchType)
    VALUES (@MemberId, @Query, 'hibrida');

    ;WITH SemanticRanked AS
    (
        SELECT b.BookId,
               ROW_NUMBER() OVER (ORDER BY VECTOR_DISTANCE('cosine', b.Embedding, @q)) AS rnk
        FROM dbo.Books b
        WHERE b.Embedding IS NOT NULL
    ),
    Semantic AS
    (
        SELECT BookId, rnk FROM SemanticRanked WHERE rnk <= 20
    ),
    Texto AS
    (
        SELECT ft.[KEY] AS BookId,
               ROW_NUMBER() OVER (ORDER BY ft.[RANK] DESC) AS rnk
        FROM FREETEXTTABLE(dbo.Books, (Title, Synopsis), @Query, LANGUAGE 3082) AS ft
    ),
    Afin AS
    (
        SELECT BookId,
               ROW_NUMBER() OVER (ORDER BY AffinityScore DESC) AS rnk
        FROM dbo.fn_MemberAffinity(@MemberId)     -- sin socio (NULL) no devuelve filas
    ),
    Ids AS
    (
        SELECT BookId FROM Semantic
        UNION
        SELECT BookId FROM Texto
        UNION
        SELECT BookId FROM Afin
    )
    SELECT TOP (@Top)
           c.BookId,
           c.Title,
           c.Authors,
           c.Genres,
           s.rnk AS PosVectorial,
           t.rnk AS PosTexto,
           f.rnk AS PosAfinidad,
           CAST(ISNULL(1.0 / (60 + s.rnk), 0)
              + ISNULL(1.0 / (60 + t.rnk), 0)
              + ISNULL(1.0 / (60 + f.rnk), 0) AS DECIMAL(9,6)) AS ScoreRRF
    FROM Ids i
    JOIN dbo.vw_BookCatalog c ON c.BookId = i.BookId
    LEFT JOIN Semantic s ON s.BookId = i.BookId
    LEFT JOIN Texto    t ON t.BookId = i.BookId
    LEFT JOIN Afin     f ON f.BookId = i.BookId
    WHERE @ExcludeRead = 0
       OR i.BookId NOT IN (SELECT BookId FROM dbo.fn_MemberBooks(@MemberId))
    ORDER BY ScoreRRF DESC, c.Title;
END;
GO
