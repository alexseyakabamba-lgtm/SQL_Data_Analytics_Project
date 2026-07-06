/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    This script performs cumulative analysis to evaluate business
    performance over time using window functions.

SQL Functions Used:
    - SUM() OVER() : Calculates cumulative (running) totals.
    - AVG() OVER() : Calculates moving averages.
    - DATETRUNC()  : Truncates a datetime value to a specified date part
===============================================================================
*/


-- ============================================================================
-- Running Total and Moving Average (Using a Derived Table)
-- ============================================================================
-- Calculates yearly sales revenue, then computes the cumulative
-- sales total and moving average of the average selling price.

SELECT
    order_date,
    total_sales,

    SUM(total_sales)
        OVER (ORDER BY order_date) AS running_total_sales,

    AVG(average_price)
        OVER (ORDER BY order_date) AS moving_average_price

FROM
(
    SELECT
        DATETRUNC(YEAR, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS average_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(YEAR, order_date)
) AS yearly_sales;



-- ============================================================================
-- Running Total and Moving Average (Using a Common Table Expression)
-- ============================================================================
-- Produces the same result as the previous query but uses a CTE
-- to improve readability and simplify more complex transformations.

WITH yearly_sales AS
(
    SELECT
        DATETRUNC(YEAR, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS average_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(YEAR, order_date)
)

SELECT
    order_date,
    total_sales,

    SUM(total_sales)
        OVER (ORDER BY order_date) AS running_total_sales,

    AVG(average_price)
        OVER (ORDER BY order_date) AS moving_average_price

FROM yearly_sales
ORDER BY order_date;
