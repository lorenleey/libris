USE Libris;
GO
SELECT 'Books' Tabla,COUNT(*) Filas FROM dbo.Books
UNION ALL SELECT 'Members',COUNT(*) FROM dbo.Members
UNION ALL SELECT 'Loans',COUNT(*) FROM dbo.Loans
UNION ALL SELECT 'Ratings',COUNT(*) FROM dbo.Ratings;
-- Originales 15/4/14/12 -> esperados 515/54/1514/1512.
SELECT COUNT(*) AS VectoresIncorrectos FROM dbo.Books
WHERE Embedding IS NULL OR VECTORPROPERTY(Embedding,'Dimensions')<>1024;
-- Esperado: 0 al terminar los 20 lotes de 25.
SELECT m.LoginName,COUNT(DISTINCT l.BookId) LibrosHistorial
FROM dbo.Members m JOIN dbo.Loans l ON l.MemberId=m.MemberId
WHERE m.LoginName LIKE N'bench500[_]%'
GROUP BY m.LoginName ORDER BY m.LoginName;
-- Esperado: 50 filas, 30 libros distintos cada una.
SELECT FULLTEXTCATALOGPROPERTY(N'LibrisCatalog','PopulateStatus') Estado,
 FULLTEXTCATALOGPROPERTY(N'LibrisCatalog','ItemCount') Indexados;
-- Indexación asíncrona: esperar si aún no llega a 515.
GO
-- Comprobar igualdad antes de medir. Ejecutar sin cambios simultáneos.
DECLARE @socio INT=(SELECT MemberId FROM dbo.Members WHERE LoginName=N'bench500_001');
SELECT BookId,AffinityScore,SeedTitle INTO #Original
FROM dbo.fn_MemberAffinity(@socio);
CREATE TABLE #Alternative(BookId INT,AffinityScore FLOAT,SeedTitle NVARCHAR(200));
INSERT #Alternative EXEC dbo.usp_TestMemberAffinity @MemberId=@socio;
SELECT COALESCE(o.BookId,a.BookId) BookId,o.AffinityScore Original,
 a.AffinityScore Alternativa
FROM #Original o FULL JOIN #Alternative a ON a.BookId=o.BookId
WHERE o.BookId IS NULL OR a.BookId IS NULL
 OR ABS(o.AffinityScore-a.AffinityScore)>0.000001
 OR (o.AffinityScore IS NULL AND a.AffinityScore IS NOT NULL)
 OR (a.AffinityScore IS NULL AND o.AffinityScore IS NOT NULL);
-- Esperado: cero diferencias en IDs y afinidad. SeedTitle puede variar
-- en empates porque la original no fija desempate; revisarlo por separado.
DROP TABLE #Original,#Alternative;
GO
-- Activar Ctrl+M para el plan real. Hacer una pasada de calentamiento,
-- después tres comparaciones, alternando el orden de las versiones.
DECLARE @socio INT=(SELECT MemberId FROM dbo.Members WHERE LoginName=N'bench500_001');
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT * FROM dbo.fn_MemberAffinity(@socio)
ORDER BY AffinityScore DESC,BookId;
EXEC dbo.usp_TestMemberAffinity @MemberId=@socio;
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
-- Contar el total del procedimiento y las lecturas de temporales.
GO
