/* ==============================================================
   LIBRIS - 07: Full-Text Search
   Crea un catálogo y un índice de texto completo sobre
   Books.Title y Books.Synopsis (idioma español, 3082).
   Requiere que Full-Text Search esté instalado en la instancia.
   Se puede ejecutar varias veces.
   ============================================================== */
USE Libris;
GO

SELECT FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') AS FullTextInstalado;   -- debe ser 1
GO

IF FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') = 1
BEGIN
    IF NOT EXISTS (SELECT 1 
                    FROM sys.fulltext_catalogs 
                    WHERE name = N'LibrisCatalog')
        CREATE FULLTEXT CATALOG LibrisCatalog AS DEFAULT;
END
ELSE
    PRINT N'Full-Text Search no está instalado: añádelo desde el instalador de SQL Server y repite este script.';
GO

IF FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') = 1
   AND NOT EXISTS (SELECT 1 
                    FROM sys.fulltext_indexes 
                    WHERE object_id = OBJECT_ID(N'dbo.Books'))
BEGIN
    -- KEY INDEX: índice único de una sola columna (la clave primaria de Books)
    CREATE FULLTEXT INDEX ON dbo.Books
    (
        Title    LANGUAGE 3082,
        Synopsis LANGUAGE 3082
    )
    KEY INDEX PK_Books ON LibrisCatalog
    WITH (CHANGE_TRACKING = AUTO);
END
GO

-- La población del índice es asíncrona: esperamos hasta 30 segundos
DECLARE @i INT = 0;
WHILE @i < 30 AND FULLTEXTCATALOGPROPERTY(N'LibrisCatalog', 'PopulateStatus') <> 0
BEGIN
    WAITFOR DELAY '00:00:01';
    SET @i += 1;
END;

SELECT FULLTEXTCATALOGPROPERTY(N'LibrisCatalog', 'PopulateStatus') AS EstadoPoblacion,   -- 0 = terminada
       FULLTEXTCATALOGPROPERTY(N'LibrisCatalog', 'ItemCount')      AS ElementosIndexados; -- 15
GO
