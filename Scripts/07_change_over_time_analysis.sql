/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    This script analyzes business performance over time by aggregating
    key metrics across different time periods.

SQL Functions Used:
    - YEAR()      : Extracts the year from a date.
    - MONTH()     : Extracts the month from a date.
    - DATETRUNC() : Truncates dates to the beginning of a specified period.
    - FORMAT()    : Formats dates for reporting purposes.
    - SUM()       : Calculates total sales and quantities.
    - COUNT()     : Counts unique customers.
===============================================================================
*/


-- ============================================================================
-- Monthly Sales Trends (Using YEAR and MONTH)
-- ============================================================================
-- Summarizes monthly business performance by calendar year and month.

SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    order_year,
    order_month;


-- ============================================================================
-- Monthly Sales Trends (Using DATETRUNC)
-- ============================================================================
-- Groups sales by the first day of each month.


SELECT
    DATETRUNC(MONTH, order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY order_month;


-- ============================================================================
-- Monthly Sales Trends (Using FORMAT)
-- ============================================================================
-- Produces a report-friendly month label.
-- FORMAT() is useful for presentation but is generally slower than
-- DATETRUNC() or YEAR()/MONTH() on large datasets.

SELECT
    FORMAT(order_date, 'yyyy-MMM') AS reporting_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY reporting_month;
