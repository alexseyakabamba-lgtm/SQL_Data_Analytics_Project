/*
===============================================================================
Dimension Exploration
===============================================================================
Purpose:
    This script explores the business dimensions to better understand the 
    available categorical data used for reporting and analysis.

SQL Functions Used:
    - DISTINCT : Returns unique values.
    - ORDER BY : Sorts the results for improved readability.
===============================================================================
*/


-- ============================================================================
-- Explore Customer Countries
-- ============================================================================
-- Retrieve the list of unique countries represented in the
-- Customer Dimension.

SELECT DISTINCT
    country
FROM gold.dim_customers
ORDER BY country;


-- ============================================================================
-- Explore Product Hierarchy
-- ============================================================================
-- Retrieves the product hierarchy consisting of category,
-- subcategory, and product name.

SELECT DISTINCT
    category,
    subcategory,
    product_name
FROM gold.dim_products
ORDER BY
    category,
    subcategory,
    product_name;

