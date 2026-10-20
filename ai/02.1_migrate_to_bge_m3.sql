/* ==============================================================
   LIBRIS - Migración de Books.Embedding a bge-m3 (1024 dimensiones)
   Cambia la columna de VECTOR(384) a VECTOR(1024) y borra los
   vectores antiguos (no se puede convertir un vector a otra
   dimensión: hay que regenerarlos con el modelo nuevo).

   Antes de ejecutar:
     - ai/02_compare_embedding_models.sql, PASOS 1 y 2 hechos
       (el modelo OllamaBgeM3 existe y devuelve 1024 dimensiones).
     - Haz las capturas de la comparación del PASO 5 de ese script
       ANTES de migrar: después el procedimiento usp_CompareModels
       dejará de funcionar (compara contra la columna de 384).

   Después de ejecutar:
     1. database/08_search.sql  (procedimientos con VECTOR(1024) y OllamaBgeM3)
     2. ai/01_generate_embeddings.sql  (regenera los 15 vectores)
     3. tests/fase6_tests.sql  (repite las capturas de búsqueda)
   ============================================================== */
USE Libris;
GO

-- ---------------------------------------------------------------
-- PASO 1. Limpiar lo temporal de la comparación
-- ---------------------------------------------------------------
DROP PROCEDURE IF EXISTS dbo.usp_CompareModels;
DROP TABLE IF EXISTS dbo.EmbeddingCompare;
GO

-- ---------------------------------------------------------------
-- PASO 2. Sustituir la columna del vector (384 -> 1024)
-- ---------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID(N'dbo.Books') AND name = N'Embedding')
    ALTER TABLE dbo.Books DROP COLUMN Embedding;
GO

ALTER TABLE dbo.Books ADD Embedding VECTOR(1024) NULL;
GO

-- ---------------------------------------------------------------
-- PASO 3. Comprobar la nueva definición
-- ---------------------------------------------------------------
SELECT name AS Columna, vector_dimensions AS Dimensiones, vector_base_type_desc AS TipoBase
FROM sys.columns
WHERE object_id = OBJECT_ID(N'dbo.Books') AND name = N'Embedding';
-- Esperado: Embedding, 1024, float32
GO
