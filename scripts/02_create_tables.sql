/* ==============================================================
   LIBRIS - 02: tablas, claves, constraints e índices
   Se puede ejecutar varias veces: borra y recrea las tablas
   (las tablas hijas primero, por las claves foráneas).
   ============================================================== */
USE Libris;
GO

DROP TABLE IF EXISTS dbo.SearchHistory, dbo.Ratings, dbo.Loans,
                     dbo.BookGenres, dbo.BookAuthors, dbo.Books,
                     dbo.Authors, dbo.Genres, dbo.Members;
GO

-- ---------------------------------------------------------------
-- Catálogo
-- ---------------------------------------------------------------
CREATE TABLE dbo.Genres
(
    GenreId INT IDENTITY(1,1) CONSTRAINT PK_Genres PRIMARY KEY,
    Name    NVARCHAR(50) NOT NULL CONSTRAINT UQ_Genres_Name UNIQUE
);

CREATE TABLE dbo.Authors
(
    AuthorId INT IDENTITY(1,1) CONSTRAINT PK_Authors PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL CONSTRAINT UQ_Authors_FullName UNIQUE
);

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

CREATE TABLE dbo.BookAuthors
(
    BookId   INT NOT NULL CONSTRAINT FK_BookAuthors_Books   REFERENCES dbo.Books(BookId),
    AuthorId INT NOT NULL CONSTRAINT FK_BookAuthors_Authors REFERENCES dbo.Authors(AuthorId),
    CONSTRAINT PK_BookAuthors PRIMARY KEY (BookId, AuthorId)
);

CREATE TABLE dbo.BookGenres
(
    BookId  INT NOT NULL CONSTRAINT FK_BookGenres_Books  REFERENCES dbo.Books(BookId),
    GenreId INT NOT NULL CONSTRAINT FK_BookGenres_Genres REFERENCES dbo.Genres(GenreId),
    CONSTRAINT PK_BookGenres PRIMARY KEY (BookId, GenreId)
);

-- ---------------------------------------------------------------
-- Socios, préstamos y valoraciones
-- ---------------------------------------------------------------
CREATE TABLE dbo.Members
(
    MemberId  INT IDENTITY(1,1) CONSTRAINT PK_Members PRIMARY KEY,
    FullName  NVARCHAR(100) NOT NULL CONSTRAINT UQ_Members_FullName UNIQUE,
    Email     NVARCHAR(150) NOT NULL CONSTRAINT UQ_Members_Email UNIQUE,
    LoginName SYSNAME       NOT NULL CONSTRAINT UQ_Members_LoginName UNIQUE,  -- usuario de BD; lo usará Row-Level Security
    JoinDate  DATE          NOT NULL CONSTRAINT DF_Members_JoinDate DEFAULT (CAST(SYSDATETIME() AS DATE))
);

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

-- ---------------------------------------------------------------
-- Trazabilidad de búsquedas (la rellenarán los procedimientos)
-- ---------------------------------------------------------------
CREATE TABLE dbo.SearchHistory
(
    SearchId   INT IDENTITY(1,1) CONSTRAINT PK_SearchHistory PRIMARY KEY,
    MemberId   INT NULL CONSTRAINT FK_SearchHistory_Members REFERENCES dbo.Members(MemberId),
    QueryText  NVARCHAR(300) NOT NULL,
    SearchType VARCHAR(10) NOT NULL
               CONSTRAINT CK_SearchHistory_Type CHECK (SearchType IN ('texto', 'vectorial', 'hibrida')),
    SearchedAt DATETIME2 NOT NULL CONSTRAINT DF_SearchHistory_SearchedAt DEFAULT (SYSDATETIME())
);
GO

-- ---------------------------------------------------------------
-- Índices (los justos: claves foráneas usadas en consultas)
-- ---------------------------------------------------------------
CREATE INDEX IX_Loans_MemberId       ON dbo.Loans (MemberId) INCLUDE (BookId, Status);
CREATE INDEX IX_Loans_BookId         ON dbo.Loans (BookId);
CREATE INDEX IX_Ratings_MemberId     ON dbo.Ratings (MemberId) INCLUDE (BookId, Score);
CREATE INDEX IX_BookAuthors_AuthorId ON dbo.BookAuthors (AuthorId);
CREATE INDEX IX_BookGenres_GenreId   ON dbo.BookGenres (GenreId);
GO
