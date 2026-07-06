/*
===============================================================================
Measures Exploration (Key Business Metrics)
===============================================================================
Purpose:
    This script calculates aggregated high-level business metrics to provide a 
    quick overview of business performance.

SQL Functions Used:
    - COUNT()    : Counts the number of records.
    - DISTINCT   : Counts unique business entities.
    - SUM()      : Calculates totals.
    - AVG()      : Calculates average values.
    - UNION ALL  : Combines multiple KPI results into a single report.
===============================================================================
*/


-- ============================================================================
-- Total Sales Revenue
-- ============================================================================
-- Calculates the total revenue generated from all sales transactions.

SELECT
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales;


-- ============================================================================
-- Total Quantity Sold
-- ============================================================================
-- Calculates the total number of units sold.

SELECT
    SUM(quantity) AS total_quantity
FROM gold.fact_sales;


-- ============================================================================
-- Average Selling Price
-- ============================================================================
-- Calculates the average selling price per unit.

SELECT
    AVG(price) AS average_price
FROM gold.fact_sales;


-- ============================================================================
-- Total Orders
-- ============================================================================
-- Counts the total number of unique customer orders.

SELECT
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;


-- ============================================================================
-- Total Products
-- ============================================================================
-- Counts the total number of products available for sale.

SELECT
    COUNT(*) AS total_products
FROM gold.dim_products;


-- ============================================================================
-- Total Customers
-- ============================================================================
-- Counts the total number of customers in the Customer Dimension.

SELECT
    COUNT(*) AS total_customers
FROM gold.dim_customers;


-- ============================================================================
-- Active Customers
-- ============================================================================
-- Counts the number of customers who have placed at least one order.

SELECT
    COUNT(DISTINCT customer_key) AS active_customers
FROM gold.fact_sales;


-- ============================================================================
-- Business KPI Summary
-- ============================================================================
-- Produces a consolidated report containing the primary business
-- metrics for executive reporting and dashboard development.

SELECT
    'Total Sales' AS measure_name,
    SUM(sales_amount) AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT
    'Total Quantity',
    SUM(quantity)
FROM gold.fact_sales

UNION ALL

SELECT
    'Average Selling Price',
    AVG(price)
FROM gold.fact_sales

UNION ALL

SELECT
    'Total Orders',
    COUNT(DISTINCT order_number)
FROM gold.fact_sales

UNION ALL

SELECT
    'Total Products',
    COUNT(*)
FROM gold.dim_products

UNION ALL

SELECT
    'Total Customers',
    COUNT(*)
FROM gold.dim_customers

UNION ALL

SELECT
    'Active Customers',
    COUNT(DISTINCT customer_key)
FROM gold.fact_sales;
