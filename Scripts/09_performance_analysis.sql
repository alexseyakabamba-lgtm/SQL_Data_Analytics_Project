/*
===============================================================================
Performance Analysis (Year-over-Year)
===============================================================================
Purpose:
    This script evaluates product performance over time by comparing
    yearly sales against historical benchmarks.

SQL Functions Used:
    - LAG()       : Retrieves sales from the previous year.
    - AVG() OVER(): Calculates the average yearly sales for each product.
    - CASE        : Classifies performance trends.
===============================================================================
*/


-- ============================================================================
-- Product Performance Analysis
-- ============================================================================
-- Compares each product's annual sales against:
--   1. Its historical average annual sales.
--   2. Its previous year's sales (Year-over-Year analysis).

WITH yearly_product_sales AS
(
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales AS f

    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key

    WHERE f.order_date IS NOT NULL

    GROUP BY
        YEAR(f.order_date),
        p.product_name
),

product_performance AS
(
    SELECT
        order_year,
        product_name,
        current_sales,

        AVG(current_sales)
            OVER (PARTITION BY product_name) AS average_sales,

        LAG(current_sales)
            OVER (
                PARTITION BY product_name
                ORDER BY order_year
            ) AS previous_year_sales

    FROM yearly_product_sales
)

SELECT

    order_year,
    product_name,
    current_sales,

    -- Comparison with Historical Average
    average_sales,
    current_sales - average_sales AS difference_from_average,

    CASE
        WHEN current_sales > average_sales THEN 'Above Average'
        WHEN current_sales < average_sales THEN 'Below Average'
        ELSE 'Average'
    END AS average_performance,

    -- Year-over-Year Comparison
    previous_year_sales,
    current_sales - previous_year_sales AS year_over_year_difference,

    CASE
        WHEN previous_year_sales IS NULL THEN 'No Prior Year'

        WHEN current_sales > previous_year_sales
            THEN 'Increase'

        WHEN current_sales < previous_year_sales
            THEN 'Decrease'

        ELSE 'No Change'
    END AS year_over_year_trend

FROM product_performance

ORDER BY
    product_name,
    order_year;
