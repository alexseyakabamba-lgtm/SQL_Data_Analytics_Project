/*
===============================================================================
View: gold.report_products
===============================================================================
Purpose:
    Creates a comprehensive product analytics view by consolidating
    product attributes, sales performance, and key performance indicators
    (KPIs) into a single reporting dataset.

    The view is intended for business intelligence, product performance
    analysis, sales reporting, inventory planning, and executive dashboards.

Report Contents:
    • Product Information
        - Product Key
        - Product Name
        - Category
        - Subcategory
        - Cost

    • Product Segmentation
        - Product Segment (High Performer, Mid-Range, Low Performer)

    • Sales History
        - Last Sale Date
        - Product Lifespan (Months)
        - Recency (Months Since Last Sale)

    • Key Performance Indicators (KPIs)
        - Total Orders
        - Total Sales
        - Total Quantity Sold
        - Total Customers
        - Average Selling Price
        - Average Order Revenue (AOR)
        - Average Monthly Revenue
===============================================================================
*/


-- ============================================================================
-- Create View: gold.report_products
-- ============================================================================

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS


/*=============================================================================
    Step 1: Base Dataset
------------------------------------------------------------------------------
    Retrieves product and sales information
    This dataset forms the foundation for all subsequent calculations.
=============================================================================*/

WITH base_query AS
(
    SELECT

        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,

        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost

    FROM gold.fact_sales AS f

    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key

    WHERE f.order_date IS NOT NULL
),


/*=============================================================================
    Step 2: Product Aggregation
------------------------------------------------------------------------------
    Aggregates sales transactions at the product level to calculate
    summary metrics required for reporting and performance analysis.
=============================================================================*/

product_aggregation AS
(
    SELECT

        product_key,
        product_name,
        category,
        subcategory,
        cost,

        MIN(order_date) AS first_sale_date,
        MAX(order_date) AS last_sale_date,

        DATEDIFF
        (
            MONTH,
            MIN(order_date),
            MAX(order_date)
        ) AS lifespan,

        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,

        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,

        ROUND
        (
            AVG
            (
                CAST(sales_amount AS FLOAT)
                / NULLIF(quantity, 0)
            ),
            2
        ) AS average_selling_price

    FROM base_query

    GROUP BY

        product_key,
        product_name,
        category,
        subcategory,
        cost
)


/*=============================================================================
    Step 3: Final Product Report
------------------------------------------------------------------------------
    Enriches aggregated metrics with business classifications and
    calculated KPIs for analytical reporting.
=============================================================================*/

SELECT

    product_key,
    product_name,
    category,
    subcategory,
    cost,

    first_sale_date,
    last_sale_date,

    DATEDIFF
    (
        MONTH,
        last_sale_date,
        GETDATE()
    ) AS recency_in_months,

    CASE
        WHEN total_sales > 50000
            THEN 'High Performer'

        WHEN total_sales >= 10000
            THEN 'Mid-Range'

        ELSE 'Low Performer'
    END AS product_segment,

    lifespan,

    total_orders,
    total_sales,
    total_quantity,
    total_customers,

    average_selling_price,

    -- Average Order Revenue (AOR)
    CASE
        WHEN total_orders = 0 THEN 0

        ELSE
            CAST(total_sales AS DECIMAL(12,2))
            / total_orders
    END AS average_order_revenue,

    -- Average Monthly Revenue
    CASE
        WHEN lifespan = 0 THEN total_sales

        ELSE
            CAST(total_sales AS DECIMAL(12,2))
            / lifespan
    END AS average_monthly_revenue

FROM product_aggregation;
