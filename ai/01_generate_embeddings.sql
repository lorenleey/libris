/* ==============================================================
   LIBRIS - Fase 5: embeddings de los libros
   Requisitos:
     - Scripts 01 a 05 ejecutados (y 06 si quieres, no influye).
     - Modelo externo OllamaEmbeddings creado (paso 5 de
       ai/00_validacion_entorno.sql).
     - Ollama funcionando y Caddy ABIERTO (proxy HTTPS en 11435).
   Ejecuta cada paso por separado y guarda una captura.
   ============================================================== */
USE Libris;
GO

-- ---------------------------------------------------------------
-- PASO 1. Comprobar que el modelo responde ANTES de tocar datos
--         (si Caddy está cerrado o el certificado falla, el
--          embedding puede salir NULL o dar error)
-- ---------------------------------------------------------------
BEGIN TRY
    DECLARE @test VECTOR(384) =
        AI_GENERATE_EMBEDDINGS(N'prueba' USE MODEL OllamaEmbeddings);

    IF @test IS NULL
        THROW 50010, N'El modelo devolvió NULL: revisa que Ollama y Caddy estén en marcha.', 1;

    SELECT N'OK: el modelo responde' AS Resultado,
           VECTORPROPERTY(@test, 'Dimensions') AS Dimensiones;   -- 384
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS Numero, ERROR_MESSAGE() AS Mensaje;
END CATCH;
GO

-- ---------------------------------------------------------------
-- PASO 2. Preparar el texto de entrada de cada libro
--         Título + autor(es) + géneros + sinopsis
-- ---------------------------------------------------------------
UPDATE b
SET EmbeddingText = CONCAT(N'Título: ',   c.Title,
                           N'. Autor: ',   c.Authors,
                           N'. Géneros: ', c.Genres,
                           N'. Sinopsis: ', c.Synopsis)
FROM dbo.Books b
JOIN dbo.vw_BookCatalog c ON c.BookId = b.BookId;
GO

SELECT BookId, EmbeddingText
FROM dbo.Books
ORDER BY BookId;
-- Esperado: 15 filas con el texto completo 

-- ---------------------------------------------------------------
-- PASO 3. Generar y guardar los embeddings (solo los que faltan)
--         Si cambias el texto o el modelo y quieres regenerarlos
--         todos, ejecuta antes:  UPDATE dbo.Books SET Embedding = NULL;
-- ---------------------------------------------------------------
UPDATE b
SET Embedding = AI_GENERATE_EMBEDDINGS(b.EmbeddingText USE MODEL OllamaEmbeddings)
FROM dbo.Books b
WHERE b.EmbeddingText IS NOT NULL
  AND b.Embedding IS NULL;
GO

-- ---------------------------------------------------------------
-- PASO 4. Verificar
-- ---------------------------------------------------------------
SELECT COUNT(*)       AS Libros,
       COUNT(Embedding) AS ConEmbedding,
       SUM(CASE WHEN Embedding IS NULL THEN 1 ELSE 0 END) AS SinEmbedding
FROM dbo.Books;
-- Esperado: 15 / 15 / 0
-- Si SinEmbedding > 0: Caddy cerrado, Ollama parado o error de certificado.
-- Vuelve a ejecutar el PASO 3 (solo procesa los que faltan).

SELECT TOP (1) Title,
       VECTORPROPERTY(Embedding, 'Dimensions') AS Dimensiones
FROM dbo.Books
WHERE Embedding IS NOT NULL;
-- Esperado: 384
GO

-- (Opcional) Ver el inicio de un vector. Si tu versión no permite el CAST
-- a texto, sáltate esta consulta: no afecta al resto.
SELECT TOP (1) Title,
       LEFT(CAST(Embedding AS NVARCHAR(MAX)), 120) AS InicioDelVector
FROM dbo.Books
WHERE Embedding IS NOT NULL;
GO

-- ---------------------------------------------------------------
-- PASO 5. Prueba de sentido: libros más parecidos a "Dune"
--         (el primero será el propio Dune con distancia 0)
-- ---------------------------------------------------------------
DECLARE @dune VECTOR(384) = (SELECT Embedding 
                              FROM dbo.Books 
                              WHERE Title = N'Dune');

SELECT TOP (6)
       Title,
       VECTOR_DISTANCE('cosine', Embedding, @dune) AS DistanciaCoseno
FROM dbo.Books
WHERE Embedding IS NOT NULL
ORDER BY DistanciaCoseno;
-- Esperado: los libros de ciencia ficción cerca de Dune y los de
-- otros géneros más lejos. Si el orden no tiene sentido, el modelo
-- (all-minilm, entrenado sobre todo en inglés) puede no ser bueno
-- con sinopsis en español: prueba un modelo multilingüe.
GO
