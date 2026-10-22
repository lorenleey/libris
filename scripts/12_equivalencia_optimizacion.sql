USE Libris;
GO

DROP TABLE IF EXISTS #Original;
DROP TABLE IF EXISTS #Optimizada;

CREATE TABLE #Original (
    BookId INT,
    AffinityScore FLOAT,
    BasadoEn NVARCHAR(200)
);

CREATE TABLE #Optimizada (
    BookId INT,
    AffinityScore FLOAT,
    BasadoEn NVARCHAR(200)
);

DECLARE @MemberId INT = (
    SELECT MemberId
    FROM dbo.Members
    WHERE LoginName = N'bench500_001'
);

INSERT INTO #Original (BookId, AffinityScore, BasadoEn)
SELECT BookId, AffinityScore, SeedTitle
FROM dbo.fn_MemberAffinity(@MemberId);

-- INSERT EXEC recoge las columnas por posición.
INSERT INTO #Optimizada (BookId, AffinityScore, BasadoEn)
EXEC dbo.usp_TestMemberAffinity @MemberId = @MemberId;

-- 1. Cantidad de resultados.
SELECT
    (SELECT COUNT(*) FROM #Original) AS FilasOriginal,
    (SELECT COUNT(*) FROM #Optimizada) AS FilasOptimizada;

-- 2. Libros ausentes o puntuaciones diferentes.
SELECT
    o.BookId AS LibroOriginal,
    p.BookId AS LibroOptimizada,
    o.AffinityScore AS PuntuacionOriginal,
    p.AffinityScore AS PuntuacionOptimizada
FROM #Original o
FULL OUTER JOIN #Optimizada p ON p.BookId = o.BookId
WHERE o.BookId IS NULL
   OR p.BookId IS NULL
   OR ABS(o.AffinityScore - p.AffinityScore) > 0.000001
   OR (o.AffinityScore IS NULL AND p.AffinityScore IS NOT NULL)
   OR (o.AffinityScore IS NOT NULL AND p.AffinityScore IS NULL);

-- 3. Diferencias en el libro usado como explicación.
SELECT
    o.BookId,
    o.BasadoEn AS ExplicacionOriginal,
    p.BasadoEn AS ExplicacionOptimizada
FROM #Original o
JOIN #Optimizada p ON p.BookId = o.BookId
WHERE o.BasadoEn <> p.BasadoEn
   OR (o.BasadoEn IS NULL AND p.BasadoEn IS NOT NULL)
   OR (o.BasadoEn IS NOT NULL AND p.BasadoEn IS NULL);