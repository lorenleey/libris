/* ==============================================================
   LIBRIS - Comparar modelos de embeddings (all-minilm vs bge-m3)
   Objetivo: comprobar con TUS datos si bge-m3 entiende mejor el
   español ANTES de migrar la tabla Books.

   No modifica Books: los vectores de bge-m3 se guardan en una
   tabla temporal de comparación (dbo.EmbeddingCompare).

   Requisitos:
     - ollama pull bge-m3 ejecutado
     - Caddy abierto (https://localhost:11435)
     - Fase 5 hecha (Books.EmbeddingText y Books.Embedding rellenos)
   Ejecuta cada paso por separado y guarda una captura.
   ============================================================== */
USE Libris;
GO

-- ---------------------------------------------------------------
-- PASO 1. Registrar el segundo modelo (mismo endpoint, otro modelo)
-- ---------------------------------------------------------------
-- DROP EXTERNAL MODEL OllamaBgeM3;   -- solo si necesitas recrearlo
CREATE EXTERNAL MODEL OllamaBgeM3
WITH (
    LOCATION   = 'https://localhost:11435/api/embed',
    API_FORMAT = 'Ollama',
    MODEL_TYPE = EMBEDDINGS,
    MODEL      = 'bge-m3'
);
GO

-- ---------------------------------------------------------------
-- PASO 2. Dimensión real de bge-m3
--   La primera llamada carga el modelo en memoria y puede tardar
--   unos segundos. Si da el error 42204, la dimensión NO es 1024:
--   anota el mensaje y pásamelo.
-- ---------------------------------------------------------------
DECLARE @v VECTOR(1024) =
    AI_GENERATE_EMBEDDINGS(N'prueba' USE MODEL OllamaBgeM3);

SELECT VECTORPROPERTY(@v, 'Dimensions') AS dimensiones;   -- esperado: 1024
GO

-- ---------------------------------------------------------------
-- PASO 3. Embeddings de bge-m3 para los 15 libros (tabla temporal)
-- ---------------------------------------------------------------
DROP TABLE IF EXISTS dbo.EmbeddingCompare;
CREATE TABLE dbo.EmbeddingCompare
(
    BookId INT NOT NULL PRIMARY KEY,
    Title  NVARCHAR(200) NOT NULL,
    EmbBge VECTOR(1024) NULL
);
GO

INSERT INTO dbo.EmbeddingCompare (BookId, Title, EmbBge)
SELECT b.BookId,
       b.Title,
       AI_GENERATE_EMBEDDINGS(b.EmbeddingText USE MODEL OllamaBgeM3)
FROM dbo.Books b
WHERE b.EmbeddingText IS NOT NULL;
GO

SELECT COUNT(*) AS Libros, COUNT(EmbBge) AS ConEmbedding FROM dbo.EmbeddingCompare;
-- Esperado: 15 / 15 (si ConEmbedding sale menor, repite el PASO 3 con Caddy abierto)
GO

-- ---------------------------------------------------------------
-- PASO 4. Procedimiento auxiliar de comparación (temporal)
--   Devuelve el top 5 de cada modelo para la misma pregunta.
-- ---------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.usp_CompareModels
    @Pregunta NVARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @qMini VECTOR(384)  = AI_GENERATE_EMBEDDINGS(@Pregunta USE MODEL OllamaEmbeddings);
    DECLARE @qBge  VECTOR(1024) = AI_GENERATE_EMBEDDINGS(@Pregunta USE MODEL OllamaBgeM3);

    SELECT TOP (5)
           N'all-minilm (384)' AS Modelo,
           b.Title,
           CAST(VECTOR_DISTANCE('cosine', b.Embedding, @qMini) AS DECIMAL(6,4)) AS DistanciaCoseno
    FROM dbo.Books b
    WHERE b.Embedding IS NOT NULL
    ORDER BY VECTOR_DISTANCE('cosine', b.Embedding, @qMini);

    SELECT TOP (5)
           N'bge-m3 (1024)' AS Modelo,
           e.Title,
           CAST(VECTOR_DISTANCE('cosine', e.EmbBge, @qBge) AS DECIMAL(6,4)) AS DistanciaCoseno
    FROM dbo.EmbeddingCompare e
    WHERE e.EmbBge IS NOT NULL
    ORDER BY VECTOR_DISTANCE('cosine', e.EmbBge, @qBge);
END;
GO

-- ---------------------------------------------------------------
-- PASO 5. Las mismas preguntas con los dos modelos
--   Criterio de éxito (orientativo): el modelo mejor pone arriba
--   los libros que un humano esperaría.
-- ---------------------------------------------------------------
-- 5.1  Esperado arriba: Dune (y otros de ciencia ficción)
EXEC dbo.usp_CompareModels @Pregunta = N'novela sobre política y poder en el espacio';

-- 5.2  Esperado arriba: 1984 y Fahrenheit 451
EXEC dbo.usp_CompareModels @Pregunta = N'un mundo vigilado donde castigan pensar distinto';

-- 5.3  Esperado arriba: Asesinato en el Orient Express, El nombre de la rosa,
--      Los hombres que no amaban a las mujeres
EXEC dbo.usp_CompareModels @Pregunta = N'detective que resuelve un crimen';

-- 5.4  Esperado arriba: El Hobbit y Un mago de Terramar
EXEC dbo.usp_CompareModels @Pregunta = N'aventura con magos y dragones';
GO

-- ---------------------------------------------------------------
-- PASO 6. Limpieza de lo temporal (el modelo OllamaBgeM3 se conserva)
--   Ejecútalo cuando hayas hecho las capturas y decidido.
-- ---------------------------------------------------------------
-- DROP PROCEDURE IF EXISTS dbo.usp_CompareModels;
-- DROP TABLE IF EXISTS dbo.EmbeddingCompare;
