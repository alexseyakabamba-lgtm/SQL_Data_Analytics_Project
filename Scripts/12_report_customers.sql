/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    Creates a customer-centric reporting view by consolidating customer
    demographics, purchasing behavior, and key business metrics into a
    single analytical dataset.

    This report is designed for business intelligence, customer analysis,
    and dashboard reporting.

Highlights:
    1. Retrieves customer demographic information and transaction history.
    2. Calculates customer age and assigns age groups.
    3. Segments customers based on purchasing behavior.
    4. Aggregates customer-level KPIs, including:
       - Total Orders
       - Total Sales
       - Total Quantity Purchased
       - Total Products Purchased
       - Customer Lifespan (Months)
    5. Calculates business metrics such as:
       - Recency (Months Since Last Purchase)
       - Average Order Value (AOV)
       - Average Monthly Spend
===============================================================================
*/


-- ============================================================================
-- Create View: gold.report_customers
-- ============================================================================

IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS

/*=============================================================================
    1. Base Query
    Retrieves customer and sales information 
=============================================================================*/
WITH base_query AS
(
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,

        c.customer_key,
        c.customer_number,

        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,

        DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age

    FROM gold.fact_sales AS f

    LEFT JOIN gold.dim_customers AS c
        ON f.customer_key = c.customer_key

    WHERE f.order_date IS NOT NULL
),

/*=============================================================================
    2. Customer Aggregation
    Calculates customer-level sales metrics.
=============================================================================*/
customer_aggregation AS
(
    SELECT

        customer_key,
        customer_number,
        customer_name,
        age,

        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,

        MAX(order_date) AS last_order_date,

        DATEDIFF
        (
            MONTH,
            MIN(order_date),
            MAX(order_date)
        ) AS lifespan

    FROM base_query

    GROUP BY

        customer_key,
        customer_number,
        customer_name,
        age
)

-- ============================================================================
-- Final Customer Report
-- ============================================================================

SELECT

    customer_key,
    customer_number,
    customer_name,
    age,

    CASE
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and Above'
    END AS age_group,

    CASE
        WHEN lifespan >= 12
             AND total_sales > 5000
            THEN 'VIP'

        WHEN lifespan >= 12
            THEN 'Regular'

        ELSE 'New'
    END AS customer_segment,

    last_order_date,

    DATEDIFF
    (
        MONTH,
        last_order_date,
        GETDATE()
    ) AS recency,

    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,

    -- Average Order Value (AOV)
    CASE
        WHEN total_orders = 0 THEN 0

        ELSE
            CAST(total_sales AS DECIMAL(12,2))
            / total_orders
    END AS avg_order_value,

    -- Average Monthly Spend
    CASE
        WHEN lifespan = 0 THEN total_sales

        ELSE
            CAST(total_sales AS DECIMAL(12,2))
            / lifespan
    END AS avg_monthly_spend

FROM customer_aggregation;
