/*
===============================================================================
Database Initialization and  Schemas
===============================================================================
Purpose:
    Initializes the DataWarehouseAnalytics database by recreating the
    database, creating the Gold schema, defining the Gold layer tables,
    and loading analytical data into the dimensional model.

    This script performs the following tasks:
        1. Drops and recreates the DataWarehouseAnalytics database.
        2. Creates the Gold schema.
        3. Creates the dimension and fact tables.
        4. Loads data into the tables using BULK INSERT.

Usage Notes:
    - Execute this script before performing analytical queries or
      building dashboards.
    - Ensure the source CSV files exist at the specified file paths.
    - Requires SQL Server permissions to create databases, schemas,
      tables, and perform BULK INSERT operations.

WARNING:
    This script permanently deletes the existing
    DataWarehouseAnalytics database (if it exists).

    All database objects and data will be lost.

    Ensure that appropriate backups have been taken before executing
    this script.
===============================================================================
*/

USE master;
GO

-- ============================================================================
-- Recreate the DataWarehouseAnalytics Database
-- ============================================================================

IF EXISTS
(
    SELECT 1
    FROM sys.databases
    WHERE name = 'DataWarehouseAnalytics'
)
BEGIN
    ALTER DATABASE DataWarehouseAnalytics
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE DataWarehouseAnalytics;
END;
GO

CREATE DATABASE DataWarehouseAnalytics;
GO

USE DataWarehouseAnalytics;
GO


-- ============================================================================
-- Create Gold Schema
-- ============================================================================

CREATE SCHEMA gold;
GO


-- ============================================================================
-- Create Gold Dimension Tables
-- ============================================================================

CREATE TABLE gold.dim_customers
(
    customer_key       INT,
    customer_id        INT,
    customer_number    NVARCHAR(50),
    first_name         NVARCHAR(50),
    last_name          NVARCHAR(50),
    country            NVARCHAR(50),
    marital_status     NVARCHAR(50),
    gender             NVARCHAR(50),
    birthdate          DATE,
    create_date        DATE
);
GO


CREATE TABLE gold.dim_products
(
    product_key        INT,
    product_id         INT,
    product_number     NVARCHAR(50),
    product_name       NVARCHAR(50),
    category_id        NVARCHAR(50),
    category           NVARCHAR(50),
    subcategory        NVARCHAR(50),
    maintenance        NVARCHAR(50),
    cost               INT,
    product_line       NVARCHAR(50),
    start_date         DATE
);
GO


-- ============================================================================
-- Create Gold Fact Table
-- ============================================================================

CREATE TABLE gold.fact_sales
(
    order_number       NVARCHAR(50),
    product_key        INT,
    customer_key       INT,
    order_date         DATE,
    shipping_date      DATE,
    due_date           DATE,
    sales_amount       INT,
    quantity           TINYINT,
    price              INT
);
GO


-- ============================================================================
-- Load Gold Dimension: Customers
-- ============================================================================

TRUNCATE TABLE gold.dim_customers;
GO

BULK INSERT gold.dim_customers
FROM 'C:\sql\sql-data-analytics-project\datasets\csv-files\gold.dim_customers.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO


-- ============================================================================
-- Load Gold Dimension: Products
-- ============================================================================

TRUNCATE TABLE gold.dim_products;
GO

BULK INSERT gold.dim_products
FROM 'C:\sql\sql-data-analytics-project\datasets\csv-files\gold.dim_products.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO


-- ============================================================================
-- Load Gold Fact Table: Sales
-- ============================================================================

TRUNCATE TABLE gold.fact_sales;
GO

BULK INSERT gold.fact_sales
FROM 'C:\sql\sql-data-analytics-project\datasets\csv-files\gold.fact_sales.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO
