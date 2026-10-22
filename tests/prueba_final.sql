USE Libris;
GO

-- 1. Volumen y embeddings.
SELECT
    COUNT(*) AS TotalLibros,
    COUNT(Embedding) AS LibrosConEmbedding,
    SUM(CASE WHEN Embedding IS NULL THEN 1 ELSE 0 END)
        AS LibrosSinEmbedding
FROM dbo.Books;

SELECT COUNT(*) AS TotalSocios
FROM dbo.Members;

-- 2. La disponibilidad debe coincidir con los préstamos abiertos.
-- Resultado esperado: ninguna fila.
SELECT b.BookId, b.Title, b.IsAvailable
FROM dbo.Books b
WHERE b.IsAvailable <>
    CASE WHEN EXISTS (
        SELECT 1
        FROM dbo.Loans l
        WHERE l.BookId = b.BookId
          AND l.Status = 'Prestado'
    ) THEN 0 ELSE 1 END;

-- 3. Comprobar qué objetos de búsqueda y RAG están instalados.
SELECT
    SCHEMA_NAME(schema_id) AS Esquema,
    name AS Objeto,
    type_desc AS Tipo
FROM sys.objects
WHERE is_ms_shipped = 0
  AND (
       name LIKE '%Search%'
    OR name LIKE '%RAG%'
    OR name LIKE '%AskLibris%'
    OR name LIKE '%Affinity%'
  )
ORDER BY name; 

DECLARE @Answer NVARCHAR(MAX);

EXEC dbo.usp_AskLibris
    @Question = N'Recomiéndame una novela de fantasía y explica por qué.',
    @Answer = @Answer OUTPUT,
    @ChatModel = N'qwen2.5:3b',
    @Top = 5,
    @ShowEvidence = 1;