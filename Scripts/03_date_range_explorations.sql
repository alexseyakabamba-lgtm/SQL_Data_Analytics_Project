/*
===============================================================================
Date Range Exploration
===============================================================================
Purpose:
    This script explores the temporal coverage of the data points
    by identifying the date ranges of key business entities.

SQL Functions Used:
    - MIN()      : Returns the earliest value in a column.
    - MAX()      : Returns the latest value in a column.
    - DATEDIFF() : Calculates the difference between two dates.
===============================================================================
*/


-- ============================================================================
-- Explore Sales Date Range
-- ============================================================================
-- Retrieves the first and last recorded order dates and calculates
-- the total time span of the sales history in months.

SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;


-- ============================================================================
-- Explore Customer Age Distribution
-- ============================================================================
-- Identifies the oldest and youngest customers based on their
-- recorded birthdates and calculates their approximate ages.

SELECT
    MIN(birthdate) AS oldest_birthdate,
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,

    MAX(birthdate) AS youngest_birthdate,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers;
