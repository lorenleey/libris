/* ==============================================================
   LIBRIS - Pruebas de la Fase 6 (búsqueda y personalización)
   Requisitos: 07_fulltext.sql y 08_search.sql ejecutados,
   embeddings generados, Ollama y Caddy en marcha.
   Ejecuta cada sección por separado y guarda una captura.
   Los resultados "esperados" son orientativos: dependen del modelo.
   ============================================================== */
USE Libris;
GO

-- ===============================================================
-- 0. El índice Full-Text está listo
-- ===============================================================
SELECT FULLTEXTCATALOGPROPERTY(N'LibrisCatalog', 'PopulateStatus') AS EstadoPoblacion,   -- 0
       FULLTEXTCATALOGPROPERTY(N'LibrisCatalog', 'ItemCount')      AS ElementosIndexados; -- 15
GO

-- ===============================================================
-- 1. Las tres búsquedas con la misma pregunta
-- ===============================================================
-- 1.1 Tradicional (por palabras)
EXEC dbo.usp_SearchBooksText     @Query = N'novela sobre política y poder en el espacio', @Top = 5;

-- 1.2 Semántica (por significado)
EXEC dbo.usp_SearchBooksSemantic @Query = N'novela sobre política y poder en el espacio', @Top = 5;

-- 1.3 Híbrida (texto + vector con RRF)
EXEC dbo.usp_SearchBooksHybrid   @Query = N'novela sobre política y poder en el espacio', @Top = 5;
-- Esperado: Dune arriba. Fíjate en PosVectorial / PosTexto / ScoreRRF.
GO

-- ===============================================================
-- 2. Una pregunta donde el significado importa más que las palabras
--    (casi no comparte palabras con las sinopsis)
-- ===============================================================
EXEC dbo.usp_SearchBooksText     @Query = N'un mundo vigilado donde castigan pensar distinto', @Top = 5;
EXEC dbo.usp_SearchBooksSemantic @Query = N'un mundo vigilado donde castigan pensar distinto', @Top = 5;
-- Esperado (orientativo): la semántica sitúa 1984 y Fahrenheit 451 arriba;
-- la de texto puede devolver menos resultados o menos relevantes.
GO

-- ===============================================================
-- 3. Recomendaciones personalizadas (solo historial del socio)
-- ===============================================================
DECLARE @ana   INT = (SELECT MemberId FROM dbo.Members WHERE LoginName = N'ana');
DECLARE @bruno INT = (SELECT MemberId FROM dbo.Members WHERE LoginName = N'bruno');
DECLARE @carla INT = (SELECT MemberId FROM dbo.Members WHERE LoginName = N'carla');
DECLARE @david INT = (SELECT MemberId FROM dbo.Members WHERE LoginName = N'david');

EXEC dbo.usp_RecommendForMember @MemberId = @ana,   @Top = 5;   -- gusto: ciencia ficción
EXEC dbo.usp_RecommendForMember @MemberId = @bruno, @Top = 5;   -- gusto: misterio
EXEC dbo.usp_RecommendForMember @MemberId = @carla, @Top = 5;   -- gusto: fantasía
EXEC dbo.usp_RecommendForMember @MemberId = @david, @Top = 5;   -- clásicos (puntuó bajo el Quijote)
-- Esperado (orientativo): cada socio recibe libros afines a su gusto, nunca
-- libros que ya tiene en su historial, y la columna BasadoEn explica el motivo.
GO

-- ===============================================================
-- 4. Búsqueda híbrida personalizada (texto + vector + perfil)
--    La misma pregunta para dos socios distintos
-- ===============================================================
DECLARE @ana   INT = (SELECT MemberId FROM dbo.Members WHERE LoginName = N'ana');
DECLARE @bruno INT = (SELECT MemberId FROM dbo.Members WHERE LoginName = N'bruno');

EXEC dbo.usp_SearchBooksHybrid @Query = N'quiero una novela con intriga y aventura', @Top = 5;                       -- anónima
EXEC dbo.usp_SearchBooksHybrid @Query = N'quiero una novela con intriga y aventura', @MemberId = @ana,   @Top = 5;   -- perfil de Ana
EXEC dbo.usp_SearchBooksHybrid @Query = N'quiero una novela con intriga y aventura', @MemberId = @bruno, @Top = 5;   -- perfil de Bruno
-- Esperado (orientativo): el orden cambia según el perfil; la columna
-- PosAfinidad muestra la tercera señal que se suma en el RRF.
GO

-- ===============================================================
-- 5. Trazabilidad: historial de búsquedas
-- ===============================================================
SELECT TOP (20) s.SearchId, m.FullName AS Socio, s.QueryText, s.SearchType, s.SearchedAt
FROM dbo.SearchHistory s
LEFT JOIN dbo.Members m ON m.MemberId = s.MemberId
ORDER BY s.SearchId DESC;
-- Esperado: una fila por búsqueda con tipo texto, vectorial o hibrida
GO
