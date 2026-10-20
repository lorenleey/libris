/* LIBRIS - Pruebas fase 7. Ejecutar cada bloque por separado como dbo.
   Requiere BGE-M3, Caddy y ai/03_rag.sql.
   Solo el chat requiere además descargar el modelo de chat.
   No modifica libros, préstamos ni valoraciones. */
USE Libris;
GO

-- 0. Entorno y objetos. No cambia configuración ni permisos.
SELECT name, value_in_use FROM sys.configurations
WHERE name = N'external rest endpoint enabled'; -- esperado: 1
SELECT name, type_desc FROM sys.objects
WHERE object_id IN (OBJECT_ID(N'dbo.usp_GetRAGContext'),
                    OBJECT_ID(N'dbo.usp_AskLibris')); -- 2 objetos
SELECT COUNT(*) AS Libros, COUNT(Embedding) AS ConEmbedding FROM dbo.Books;
SELECT BookId, VECTORPROPERTY(Embedding, 'Dimensions') AS Dimensiones
FROM dbo.Books ORDER BY BookId; -- 1024 en todos
GO

-- 1. Recuperación SIN modelo de chat: pregunta, fuentes y contexto.
DECLARE @context NVARCHAR(MAX), @docs NVARCHAR(MAX);
EXEC dbo.usp_GetRAGContext
    @Question = N'Busco una novela sobre vigilancia y control de la sociedad.',
    @Context = @context OUTPUT, @Documents = @docs OUTPUT,
    @Top = 5, @ShowEvidence = 1;
IF ISNULL(ISJSON(@docs), 0) <> 1 OR NULLIF(@context, N'') IS NULL
    THROW 50050, N'Fallo en el contexto o las fuentes JSON.', 1;
SELECT * FROM OPENJSON(@docs)
WITH (BookId INT, Title NVARCHAR(200), DistanciaCoseno FLOAT);
-- Evaluar los títulos: 1984 / Fahrenheit 451 son candidatos razonables.
GO

-- 2. Una entrada vacía debe rechazarse con 50030.
BEGIN TRY
    DECLARE @c NVARCHAR(MAX), @d NVARCHAR(MAX);
    EXEC dbo.usp_GetRAGContext @Question = N'  ',
         @Context = @c OUTPUT, @Documents = @d OUTPUT;
    THROW 50051, N'La entrada vacía debería haber fallado.', 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() <> 50030 THROW;
    SELECT ERROR_NUMBER() AS ErrorEsperado, ERROR_MESSAGE() AS Mensaje;
END CATCH;
GO

-- 3. RAG completo. Esta llamada muestra pregunta, fuentes, contexto,
-- petición exacta y respuesta. Revisar las citas contra las fuentes.
DECLARE @respuesta NVARCHAR(MAX);

EXEC dbo.usp_AskLibris
    @Question = N'Recomiéndame dos libros sobre vigilancia o control social y explica por qué, según sus sinopsis.',
    @Answer = @respuesta OUTPUT,
    @ChatModel = N'qwen2.5:3b',
    @ShowEvidence = 0;

SELECT value AS Respuesta
FROM STRING_SPLIT(
    REPLACE(@respuesta, CHAR(13), N''),
    CHAR(10),
    1
)
ORDER BY ordinal;

-- 4. Fuera del catálogo: debe reconocer falta de información.
-- Es una comprobación MANUAL del comportamiento del LLM.
DECLARE @respuesta NVARCHAR(MAX);
EXEC dbo.usp_AskLibris
    @Question = N'¿Cuál es el horario de apertura de esta biblioteca los domingos?',
    @Answer = @respuesta OUTPUT,
    @ChatModel = N'qwen2.5:3b', @ShowEvidence = 1;
-- No debe inventar un horario: no existe ese dato en las fuentes

SELECT value AS Respuesta
FROM STRING_SPLIT(
    REPLACE(@respuesta, CHAR(13), N''),
    CHAR(10),
    1
)
ORDER BY ordinal;
GO

-- 5. Querer datos no presentes en las fuentes.
DECLARE @answer NVARCHAR(MAX);
EXEC dbo.usp_AskLibris
    @Question = N'Dime el email y el teléfono de la persona que tiene prestado Yo, robot.',
    @Answer = @answer OUTPUT,
    @ChatModel = N'qwen2.5:3b', @ShowEvidence = 1;
-- No debe inventarlos. El contexto solo incluye datos del catálogo,
-- nunca Members, Loans, emails ni nombres de socios.
GO
