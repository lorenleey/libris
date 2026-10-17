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
    SET IsAvailable = 
        CASE WHEN EXISTS (
            SELECT 1
             FROM dbo.Loans l
            WHERE l.BookId = b.BookId
             AND l.Status = 'Prestado'
             )  THEN 0
                ELSE 1
        END
    FROM dbo.Books b
    WHERE b.BookId IN (SELECT BookId FROM inserted
                       UNION
                       SELECT BookId FROM deleted);
END;
GO

-- ---------------------------------------------------------------
-- PROCEDURE: 
-- @LoanId devuelve el identificador creado; es opcional.
-- Errores:
-- 50001: socio inexistente.
-- 50002: libro inexistente o no disponible.e
-- ---------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.usp_RegisterLoan
    @MemberId INT,
    @BookId INT,
    @LoanId INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @initialTranCount INT = @@TRANCOUNT;
    SET @LoanId = NULL;

    BEGIN TRY
    -- Iniciar una transacción propia o guardar un punto
        -- dentro de la transacción del llamador.
        IF @initialTranCount = 0
        BEGIN
            BEGIN TRANSACTION;
        END
        ELSE 
        BEGIN 
            SAVE TRANSACTION RegisterLoanSave;
        END;


        IF NOT EXISTS (SELECT 1 FROM dbo.Members WHERE MemberId = @MemberId)
        BEGIN 
            THROW 50001, N'El socio no existe.', 1;
        END;

         -- Mantener el bloqueo hasta terminar la transacción:
        -- dos llamadas al procedimiento no pueden prestar
        -- simultáneamente el mismo libro.

        IF NOT EXISTS (SELECT 1
                       FROM dbo.Books WITH (UPDLOCK, HOLDLOCK)
                       WHERE BookId = @BookId AND IsAvailable = 1)
        BEGIN 
            THROW 50002, N'El libro no existe o no está disponible.', 1;
        END;

        INSERT INTO dbo.Loans (BookId, MemberId, LoanDate, ReturnDate, Status)
        VALUES (@BookId, @MemberId, CAST(SYSDATETIME() AS DATE), NULL, 'Prestado');

        SET @LoanId = CONVERT(INT, SCOPE_IDENTITY());

        -- El trigger ya ha actualizado Books.IsAvailable
        IF @initialTranCount = 0
        BEGIN
            COMMIT TRANSACTION;
        END;
    END TRY
    BEGIN CATCH
        SET @LoanId = NULL;

        IF @initialTranCount = 0
        BEGIN
            IF XACT_STATE() <> 0
                ROLLBACK TRANSACTION;
        END
        ELSE IF XACT_STATE() = 1
        BEGIN
            ROLLBACK TRANSACTION RegisterLoanSave;
        END;

        -- Si la transacción externa está inutilizable
        -- (XACT_STATE = -1), el llamador debe revertirla.
        THROW;
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

        UPDATE dbo.Loans
        SET Status     = 'Terminado',
            ReturnDate = CAST(SYSDATETIME() AS DATE)
        WHERE LoanId = @LoanId
          AND Status = 'Prestado';

        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50003, N'El préstamo no existe o ya estaba devuelto.', 1;
        END;

END;
GO
