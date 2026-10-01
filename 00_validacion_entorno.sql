/* ==============================================================
   LIBRIS - Validación técnica del entorno (Fase 1, días 1-2)
   Objetivo: comprobar que SQL Server 2025 puede generar un
   embedding con Ollama y guardarlo en una columna VECTOR.

   Ejecuta SECCIÓN A SECCIÓN en SSMS (no todo de golpe) y guarda
   una captura del resultado de cada paso para el informe.
   ============================================================== */

-- ---------------------------------------------------------------
-- PASO 1. Versión y componentes
-- ---------------------------------------------------------------
SELECT @@VERSION AS version_sql;
SELECT SERVERPROPERTY('ProductMajorVersion') AS major_version;            -- 17 = SQL Server 2025
SELECT FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') AS full_text;       -- 1 = instalado
GO

-- ---------------------------------------------------------------
-- PASO 2. Base de datos del proyecto
-- ---------------------------------------------------------------
IF DB_ID(N'Libris') IS NULL
    CREATE DATABASE Libris;
GO
USE Libris;
GO

-- ---------------------------------------------------------------
-- PASO 3. Configuración necesaria
-- ---------------------------------------------------------------
-- Permite que SQL Server llame a endpoints REST (Ollama)
EXECUTE sp_configure 'external rest endpoint enabled', 1;
RECONFIGURE WITH OVERRIDE;
GO

-- Necesario para vector index / VECTOR_SEARCH en SQL Server 2025 (preview).
-- Si el PASO 5 falla indicando que la característica no está disponible,
-- este es el primer sospechoso.
ALTER DATABASE SCOPED CONFIGURATION SET PREVIEW_FEATURES = ON;
GO

-- ---------------------------------------------------------------
-- PASO 4. Comprobación previa FUERA de SQL Server (PowerShell)
-- ---------------------------------------------------------------
-- SQL Server solo acepta endpoints HTTPS con certificado de confianza.
-- Ollama escucha en HTTP (puerto 11434), así que hace falta un proxy
-- TLS delante (por ejemplo en https://localhost:11435).
--
--   ollama pull all-minilm
--
--   Invoke-RestMethod -Uri https://localhost:11435/api/embed `
--     -Method Post -ContentType 'application/json' `
--     -Body '{"model":"all-minilm","input":"hola"}'
--
-- Si PowerShell devuelve un array "embeddings", la parte de red y
-- certificados está resuelta. Si da error de certificado, arréglalo
-- antes de seguir: SQL Server fallará por el mismo motivo.

-- ---------------------------------------------------------------
-- PASO 5. Registrar el modelo de embeddings
-- ---------------------------------------------------------------
-- DROP EXTERNAL MODEL OllamaEmbeddings;   -- solo si necesitas recrearlo
CREATE EXTERNAL MODEL OllamaEmbeddings
WITH (
    LOCATION   = 'https://localhost:11435/api/embed',
    API_FORMAT = 'Ollama',
    MODEL_TYPE = EMBEDDINGS,
    MODEL      = 'all-minilm'
);
GO

-- ---------------------------------------------------------------
-- PASO 6. Primer embedding
-- ---------------------------------------------------------------
SELECT AI_GENERATE_EMBEDDINGS(
           N'novela de ciencia ficción'
           USE MODEL OllamaEmbeddings) AS embedding;
GO

-- ---------------------------------------------------------------
-- PASO 7. Dimensión real del vector
-- ---------------------------------------------------------------
-- all-minilm devuelve 384 dimensiones. Si usas otro modelo, ajusta
-- el número: la columna VECTOR(n) de Libris dependerá de este valor.
DECLARE @v VECTOR(384) =
    AI_GENERATE_EMBEDDINGS(N'prueba' USE MODEL OllamaEmbeddings);
SELECT VECTORPROPERTY(@v, 'Dimensions') AS dimensiones;
GO

-- ---------------------------------------------------------------
-- PASO 8. Almacenar y comparar (prueba de similitud semántica)
-- ---------------------------------------------------------------
DROP TABLE IF EXISTS dbo.EmbeddingSmokeTest;
CREATE TABLE dbo.EmbeddingSmokeTest
(
    id        INT IDENTITY(1,1) PRIMARY KEY,
    texto     NVARCHAR(400) NOT NULL,
    embedding VECTOR(384)   NOT NULL
);
GO

INSERT INTO dbo.EmbeddingSmokeTest (texto, embedding)
SELECT t.texto,
       AI_GENERATE_EMBEDDINGS(t.texto USE MODEL OllamaEmbeddings)
FROM (VALUES
    (N'Dune: epopeya de ciencia ficción sobre política, poder y guerra en un planeta desértico'),
    (N'Fundación: un matemático predice la caída de un imperio galáctico'),
    (N'Recetas tradicionales de cocina mediterránea para cada día'),
    (N'Manual de jardinería: cómo cuidar plantas de interior')
) AS t(texto);
GO

DECLARE @q VECTOR(384) =
    AI_GENERATE_EMBEDDINGS(
        N'novela sobre política y poder en el espacio'
        USE MODEL OllamaEmbeddings);

SELECT texto,
       VECTOR_DISTANCE('cosine', embedding, @q) AS distancia_coseno
FROM dbo.EmbeddingSmokeTest
ORDER BY distancia_coseno;   -- menor distancia = más parecido
GO

/* RESULTADO ESPERADO: los dos libros de ciencia ficción arriba y
   cocina/jardinería abajo. Si el orden no tiene sentido, anota el
   resultado: puede indicar que all-minilm (entrenado sobre todo en
   inglés) no sirve bien para sinopsis en español y conviene probar
   un modelo multilingüe antes de fijar la dimensión del VECTOR. */

-- Limpieza al terminar la validación:
-- DROP TABLE IF EXISTS dbo.EmbeddingSmokeTest;
