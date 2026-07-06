/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    This script segments products and customers into meaningful business
    groups to support targeted analysis and decision-making.

SQL Functions Used:
    - CASE        : Defines custom segmentation rules.
    - SUM()       : Calculates total customer spending.
    - MIN(), MAX(): Determines customer activity periods.
    - DATEDIFF()  : Calculates customer lifespan.
    - COUNT()     : Counts records within each segment.
    - GROUP BY    : Aggregates data by segment.
===============================================================================
*/


-- ============================================================================
-- Product Segmentation by Cost
-- ============================================================================
-- Groups products into predefined cost ranges and counts the number
-- of products within each segment.

WITH product_segments AS
(
    SELECT
        product_key,
        product_name,
        cost,

        CASE
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 499 THEN '100 - 499'
            WHEN cost BETWEEN 500 AND 999 THEN '500 - 999'
            ELSE '1,000 and Above'
        END AS cost_range

    FROM gold.dim_products
)

SELECT
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;



-- ============================================================================
-- Customer Segmentation by Spending Behavior
-- ============================================================================
-- Classifies customers into business segments based on:
--   • Customer lifespan (months between first and last purchase)
--   • Total spending
--
-- Segment Definitions:
--   • VIP      : Customer history of at least 12 months and total spending
--                greater than €5,000.
--   • Regular  : Customer history of at least 12 months and total spending
--                of €5,000 or less.
--   • New      : Customer history of less than 12 months.

WITH customer_spending AS
(
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(f.order_date) AS first_order_date,
        MAX(f.order_date) AS last_order_date,
        DATEDIFF(
            MONTH,
            MIN(f.order_date),
            MAX(f.order_date)
        ) AS customer_lifespan_months

    FROM gold.fact_sales AS f

    LEFT JOIN gold.dim_customers AS c
        ON f.customer_key = c.customer_key

    GROUP BY
        c.customer_key
),

customer_segments AS
(
    SELECT
        customer_key,

        CASE
            WHEN customer_lifespan_months >= 12
                 AND total_spending > 5000
                THEN 'VIP'

            WHEN customer_lifespan_months >= 12
                THEN 'Regular'

            ELSE 'New'
        END AS customer_segment

    FROM customer_spending
)

SELECT
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM customer_segments
GROUP BY customer_segment
ORDER BY total_customers DESC;
