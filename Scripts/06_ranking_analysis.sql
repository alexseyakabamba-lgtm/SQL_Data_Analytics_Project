/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    This script ranks business entities based on key performance metrics
    to identify top and bottom performers.

SQL Functions Used:
    - TOP()        : Returns the highest or lowest N records.
    - RANK()       : Assigns rankings while allowing ties.
    - SUM()        : Calculates total sales revenue.
    - COUNT()      : Counts customer orders.
    - GROUP BY     : Aggregates data by business entity.
    - ORDER BY     : Sorts ranked results.
===============================================================================
*/


-- ============================================================================
-- Top 5 Products by Sales Revenue (Using TOP)
-- ============================================================================
-- Identifies the five products that have generated the highest revenue.

SELECT TOP (5)
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;


-- ============================================================================
-- Top 5 Products by Sales Revenue (Using RANK)
-- ============================================================================
-- Demonstrates the use of the RANK() window function.
-- Unlike TOP, this approach preserves ties and allows more flexible
-- ranking logic.

SELECT *
FROM
(
    SELECT
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        RANK() OVER
            (ORDER BY SUM(f.sales_amount) DESC) AS product_rank
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    GROUP BY p.product_name
) AS ranked_products
WHERE product_rank <= 5
ORDER BY product_rank;


-- ============================================================================
-- Bottom 5 Products by Sales Revenue
-- ============================================================================
-- Identifies the five products that generated the lowest revenue.

SELECT TOP (5)
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC;


-- ============================================================================
-- Top 10 Customers by Revenue
-- ============================================================================
-- Identifies the customers who have generated the highest lifetime
-- sales revenue.

SELECT TOP (10)
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON f.customer_key = c.customer_key
GROUP BY
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;


-- ============================================================================
-- Bottom 3 Customers by Number of Orders
-- ============================================================================
-- Identifies the customers with the fewest recorded orders.

SELECT TOP (3)
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON f.customer_key = c.customer_key
GROUP BY
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders ASC;
