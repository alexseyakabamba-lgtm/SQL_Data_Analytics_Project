/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    This script explores the metadata of the data warehouse by querying
    the INFORMATION_SCHEMA views.

    It can be used to:
    - List all tables available in the database.
    - Identify the schema and type of each table.
    - Inspect the structure of individual tables.
    - Review column names, data types, nullability, and lengths.

Views Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

-- ============================================================================
-- List All Tables
-- ============================================================================
-- Retrieves all user tables and views in the current database.

SELECT
    TABLE_CATALOG,
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
ORDER BY
    TABLE_SCHEMA,
    TABLE_NAME;


-- ============================================================================
-- Inspect Table Structure
-- ============================================================================
-- Displays the column definitions for the Customer Dimension.


SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';
