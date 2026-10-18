/* ==============================================================
   LIBRIS - 06 (deshacer): elimina la seguridad de Libris
   Úsalo si necesitas volver a ejecutar 02_create_tables.sql
   (la política RLS y la función con SCHEMABINDING impiden
   borrar o recrear las tablas).
   ============================================================== */
USE Libris;
GO

IF EXISTS (SELECT 1 FROM sys.security_policies WHERE name = N'LibrisPolicy')
    DROP SECURITY POLICY Security.LibrisPolicy;
GO

DROP FUNCTION IF EXISTS Security.fn_MemberRowAccess;
GO

IF OBJECT_ID(N'dbo.Members', N'U') IS NOT NULL
   AND EXISTS (SELECT 1 FROM sys.masked_columns
               WHERE object_id = OBJECT_ID(N'dbo.Members') AND name = N'Email')
    ALTER TABLE dbo.Members ALTER COLUMN Email DROP MASKED;
GO

DROP VIEW IF EXISTS dbo.vw_MyProfile;
GO

-- Primero los usuarios y después los roles
DROP USER IF EXISTS ana;
DROP USER IF EXISTS bruno;
DROP USER IF EXISTS carla;
DROP USER IF EXISTS david;
DROP USER IF EXISTS admin_libris;
GO

DROP ROLE IF EXISTS rol_socio;
DROP ROLE IF EXISTS rol_admin;
GO

DROP SCHEMA IF EXISTS Security;
GO
