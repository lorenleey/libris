/* ==============================================================
   LIBRIS - 05: procedimientos almacenados y trigger
   Se puede ejecutar varias veces (CREATE OR ALTER).
   ============================================================== */
USE Libris;
GO

-- ---------------------------------------------------------------
-- TRIGGER: mantiene Books.IsAvailable según los préstamos abiertos
-- Se dispara al insertar, modificar o borrar préstamos y recalcula
-- solo los libros afectados.
-- ---------------------------------------------------------------
CREATE OR ALTER TRIGGER dbo.trg_Loans_UpdateAvailability
ON dbo.Loans
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE b
    SET IsAvailable = CASE
                          WHEN EXISTS (SELECT 1
                                       FROM dbo.Loans l
                                       WHERE l.BookId = b.BookId
                                         AND l.Status = 'Prestado')
                          THEN 0
                          ELSE 1
                      END
    FROM dbo.Books b
    WHERE b.BookId IN (SELECT BookId FROM inserted
                       UNION
                       SELECT BookId FROM deleted);
END;
GO

-- ---------------------------------------------------------------
-- PROCEDURE: registrar un préstamo (con TRY...CATCH y transacción)
-- Errores propios: 50001 socio inexistente, 50002 libro no disponible
-- ---------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.usp_RegisterLoan
    @MemberId INT,
    @BookId   INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.Members WHERE MemberId = @MemberId)
            THROW 50001, N'El socio no existe.', 1;

        -- UPDLOCK/HOLDLOCK evita que dos sesiones presten el mismo libro a la vez
        IF NOT EXISTS (SELECT 1
                       FROM dbo.Books WITH (UPDLOCK, HOLDLOCK)
                       WHERE BookId = @BookId AND IsAvailable = 1)
            THROW 50002, N'El libro no existe o no está disponible.', 1;

        INSERT INTO dbo.Loans (BookId, MemberId, LoanDate, ReturnDate, Status)
        VALUES (@BookId, @MemberId, CAST(SYSDATETIME() AS DATE), NULL, 'Prestado');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;   -- relanza el error original
    END CATCH;
END;
GO

-- ---------------------------------------------------------------
-- PROCEDURE: devolver un préstamo (marca el libro como terminado)
-- Error propio: 50003 préstamo inexistente o ya devuelto
-- ---------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.usp_ReturnLoan
    @LoanId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE dbo.Loans
        SET Status     = 'Terminado',
            ReturnDate = CAST(SYSDATETIME() AS DATE)
        WHERE LoanId = @LoanId
          AND Status = 'Prestado';

        IF @@ROWCOUNT = 0
            THROW 50003, N'El préstamo no existe o ya estaba devuelto.', 1;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO
