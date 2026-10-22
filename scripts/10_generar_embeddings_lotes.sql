/* Ejecutar después de 09_importar_ampliacion.sql, como dbo.
   Reanudable: solo libros con Embedding NULL. Una llamada por libro.
   Requiere OllamaBgeM3 -> bge-m3, Caddy y VECTOR(1024).
   No envolver todo el lote en una transacción externa. */
USE Libris;
GO
SET NOCOUNT ON;
IF USER_NAME()<>N'dbo' THROW 50200,N'Ejecuta como dbo.',1;
IF @@TRANCOUNT<>0 THROW 50201,N'No uses una transacción externa.',1;
DECLARE @id INT,@text NVARCHAR(MAX),@v VECTOR(1024),@done INT=0;
-- Máximo por ejecución. Repetir el archivo para procesar los siguientes.
DECLARE @BatchSize INT=50;
WHILE @done<@BatchSize
BEGIN
 SET @id=NULL; SET @text=NULL; SET @v=NULL;
 SELECT TOP(1) @id=BookId,@text=EmbeddingText FROM dbo.Books
 WHERE Embedding IS NULL AND NULLIF(EmbeddingText,N'') IS NOT NULL ORDER BY BookId;
 IF @id IS NULL BREAK;
 -- Si falla se conserva el progreso de los libros anteriores.
 SET @v=AI_GENERATE_EMBEDDINGS(@text USE MODEL OllamaBgeM3);
 IF @v IS NULL THROW 50202,N'Embedding NULL. Se conserva el progreso anterior; revisar conexión.',1;
 UPDATE dbo.Books SET Embedding=@v WHERE BookId=@id AND Embedding IS NULL;
 SET @done+=1;
 RAISERROR(N'Libro %d procesado. Progreso de este lote: %d.',0,1,@id,@done) WITH NOWAIT;
END;
SELECT @done AS ProcesadosEnEsteLote,COUNT(*) AS Libros,
 COUNT(Embedding) AS ConEmbedding,
 SUM(CASE WHEN Embedding IS NULL THEN 1 ELSE 0 END) AS Pendientes
FROM dbo.Books;
GO
