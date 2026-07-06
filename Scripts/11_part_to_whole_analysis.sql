/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    This script analyzes the contribution of individual categories to the
    overall business performance.

SQL Functions Used:
    - SUM()        : Calculates total sales by category.
    - SUM() OVER() : Calculates overall sales across all categories.
    - ROUND()      : Formats percentage values for reporting.
===============================================================================
*/


-- ============================================================================
-- Sales Contribution by Product Category
-- ============================================================================
-- Calculates total sales for each product category and determines
-- its percentage contribution to overall sales.

WITH category_sales AS
(
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales AS f

    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key

    GROUP BY
        p.category
)

SELECT
    category,
    total_sales,

    SUM(total_sales)
        OVER () AS overall_sales,

    ROUND(
        total_sales * 100.0
        / NULLIF(SUM(total_sales) OVER (),0),
        2
    ) AS percentage_of_total_sales

FROM category_sales

ORDER BY total_sales DESC;
