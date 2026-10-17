/* ==============================================================
   LIBRIS - 02: tablas, claves, constraints e índices
   Crea solo los objetos que faltan, sin borrar datos.
   No modifica la definición de tablas existentes; para eso usar ALTER TABLE.
   ============================================================== */
USE Libris;
GO


-- ---------------------------------------------------------------
-- Catálogo
-- ---------------------------------------------------------------
IF OBJECT_ID(N'dbo.Genres', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Genres
(
    GenreId INT IDENTITY(1,1) CONSTRAINT PK_Genres PRIMARY KEY,
    Name    NVARCHAR(50) NOT NULL CONSTRAINT UQ_Genres_Name UNIQUE
);
END;

IF OBJECT_ID(N'dbo.Authors', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Authors
(
    AuthorId INT IDENTITY(1,1) CONSTRAINT PK_Authors PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL CONSTRAINT UQ_Authors_FullName UNIQUE
);
END;

IF OBJECT_ID(N'dbo.Books', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Books
(
    BookId        INT IDENTITY(1,1) CONSTRAINT PK_Books PRIMARY KEY,
    Title         NVARCHAR(200) NOT NULL CONSTRAINT UQ_Books_Title UNIQUE,
    Isbn          CHAR(13)      NOT NULL CONSTRAINT UQ_Books_Isbn UNIQUE
                                CONSTRAINT CK_Books_Isbn CHECK (Isbn NOT LIKE '%[^0-9]%'),
    Synopsis      NVARCHAR(1000) NOT NULL,
    PublishedYear SMALLINT      NOT NULL
                                CONSTRAINT CK_Books_Year CHECK (PublishedYear BETWEEN 1000 AND 2100),
    IsAvailable   BIT           NOT NULL CONSTRAINT DF_Books_IsAvailable DEFAULT (1),
    EmbeddingText NVARCHAR(MAX) NULL,   -- texto preparado (título + autor + géneros + sinopsis); se rellena en la fase de embeddings
    Embedding     VECTOR(384)   NULL    -- 384 = all-minilm. Si cambias de modelo, cambia este número
);
END;

IF OBJECT_ID(N'dbo.BookAuthors', N'U') IS NULL
BEGIN
CREATE TABLE dbo.BookAuthors
(
    BookId   INT NOT NULL CONSTRAINT FK_BookAuthors_Books   REFERENCES dbo.Books(BookId),
    AuthorId INT NOT NULL CONSTRAINT FK_BookAuthors_Authors REFERENCES dbo.Authors(AuthorId),
    CONSTRAINT PK_BookAuthors PRIMARY KEY (BookId, AuthorId)
);
END;

IF OBJECT_ID(N'dbo.BookGenres', N'U') IS NULL
BEGIN
CREATE TABLE dbo.BookGenres
(
    BookId  INT NOT NULL CONSTRAINT FK_BookGenres_Books  REFERENCES dbo.Books(BookId),
    GenreId INT NOT NULL CONSTRAINT FK_BookGenres_Genres REFERENCES dbo.Genres(GenreId),
    CONSTRAINT PK_BookGenres PRIMARY KEY (BookId, GenreId)
);
END;

-- ---------------------------------------------------------------
-- Socios, préstamos y valoraciones
-- ---------------------------------------------------------------
IF OBJECT_ID(N'dbo.Members', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Members
(
    MemberId  INT IDENTITY(1,1) CONSTRAINT PK_Members PRIMARY KEY,
    FullName  NVARCHAR(100) NOT NULL CONSTRAINT UQ_Members_FullName UNIQUE,
    Email     NVARCHAR(150) NOT NULL CONSTRAINT UQ_Members_Email UNIQUE,
    LoginName SYSNAME       NOT NULL CONSTRAINT UQ_Members_LoginName UNIQUE,  -- usuario de BD; lo usará Row-Level Security
    JoinDate  DATE          NOT NULL CONSTRAINT DF_Members_JoinDate DEFAULT (CAST(SYSDATETIME() AS DATE))
);
END;

IF OBJECT_ID(N'dbo.Loans', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Loans
(
    LoanId     INT IDENTITY(1,1) CONSTRAINT PK_Loans PRIMARY KEY,
    BookId     INT NOT NULL CONSTRAINT FK_Loans_Books   REFERENCES dbo.Books(BookId),
    MemberId   INT NOT NULL CONSTRAINT FK_Loans_Members REFERENCES dbo.Members(MemberId),
    LoanDate   DATE NOT NULL,
    ReturnDate DATE NULL,
    Status     VARCHAR(10) NOT NULL CONSTRAINT CK_Loans_Status CHECK (Status IN ('Prestado', 'Terminado')),
    CONSTRAINT CK_Loans_Dates CHECK (ReturnDate IS NULL OR ReturnDate >= LoanDate),
    CONSTRAINT CK_Loans_StatusReturn CHECK (
        (Status = 'Prestado'  AND ReturnDate IS NULL) OR
        (Status = 'Terminado' AND ReturnDate IS NOT NULL))
);
END;

IF OBJECT_ID(N'dbo.Ratings', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Ratings
(
    RatingId INT IDENTITY(1,1) CONSTRAINT PK_Ratings PRIMARY KEY,
    BookId   INT NOT NULL CONSTRAINT FK_Ratings_Books   REFERENCES dbo.Books(BookId),
    MemberId INT NOT NULL CONSTRAINT FK_Ratings_Members REFERENCES dbo.Members(MemberId),
    Score    TINYINT NOT NULL CONSTRAINT CK_Ratings_Score CHECK (Score BETWEEN 1 AND 5),
    Comment  NVARCHAR(300) NULL,
    RatedAt  DATETIME2 NOT NULL CONSTRAINT DF_Ratings_RatedAt DEFAULT (SYSDATETIME()),
    CONSTRAINT UQ_Ratings_Book_Member UNIQUE (BookId, MemberId)   -- una valoración por socio y libro
);
END;

-- ---------------------------------------------------------------
-- Trazabilidad de búsquedas (la rellenarán los procedimientos)
-- ---------------------------------------------------------------
IF OBJECT_ID(N'dbo.SearchHistory', N'U') IS NULL
BEGIN
CREATE TABLE dbo.SearchHistory
(
    SearchId   INT IDENTITY(1,1) CONSTRAINT PK_SearchHistory PRIMARY KEY,
    MemberId   INT NULL CONSTRAINT FK_SearchHistory_Members REFERENCES dbo.Members(MemberId),
    QueryText  NVARCHAR(300) NOT NULL,
    SearchType VARCHAR(10) NOT NULL
               CONSTRAINT CK_SearchHistory_Type CHECK (SearchType IN ('texto', 'vectorial', 'hibrida')),
    SearchedAt DATETIME2 NOT NULL CONSTRAINT DF_SearchHistory_SearchedAt DEFAULT (SYSDATETIME())
);
END;
GO

-- ---------------------------------------------------------------
-- Índices (los justos: claves foráneas usadas en consultas)
-- ---------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.Loans') AND name = N'IX_Loans_MemberId'
)
BEGIN
    CREATE INDEX IX_Loans_MemberId       ON dbo.Loans (MemberId) INCLUDE (BookId, Status);
END;
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.Loans') AND name = N'IX_Loans_BookId'
)
BEGIN
    CREATE INDEX IX_Loans_BookId         ON dbo.Loans (BookId);
END;
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.Ratings') AND name = N'IX_Ratings_MemberId'
)
BEGIN
    CREATE INDEX IX_Ratings_MemberId     ON dbo.Ratings (MemberId) INCLUDE (BookId, Score);
END;
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.BookAuthors') AND name = N'IX_BookAuthors_AuthorId'
)
BEGIN
    CREATE INDEX IX_BookAuthors_AuthorId ON dbo.BookAuthors (AuthorId);
END;
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.BookGenres') AND name = N'IX_BookGenres_GenreId'
)
BEGIN
    CREATE INDEX IX_BookGenres_GenreId   ON dbo.BookGenres (GenreId);
END;
GO
