/* LIBRIS - 01: crear la base de datos (se puede ejecutar varias veces) */
IF DB_ID(N'Libris') IS NULL
    CREATE DATABASE Libris;
GO
