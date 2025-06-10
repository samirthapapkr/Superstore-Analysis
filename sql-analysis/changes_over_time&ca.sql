/*
=============================
Change Over Time Analysis
=============================
Purpose:
- To track trends, growth, and changes in key metrics over time.
- For time-series analysis and identifying seasonality
- To measure growth or decline over specific periods.

SQL Functions Used:
- Date Functions: DATEPART(), DATETRUNC(), FORMAT()
- Aggregate Functions: SUM(), COUNT(), AVG()
=================================
*/

-- Analyse sales performance over time
-- Quick Date Functions
SELECT
EXTRACT(YEAR FROM order_date) AS order_year,
EXTRACT(MONTH FROM order_date) AS order_month,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY
order_year,
order_month
ORDER BY
order_year,
order_month;

--DATE_TRUNC
SELECT
TO_CHAR(DATE_TRUNC('month', order_date), 'Mon YYYY') AS order_month,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY
order_month
ORDER BY
MIN(order_date);

/*
=========================================================================
Cumulative Analysis
=========================================================================
Purpose:
- To calculate running totals or moving averages for key metrics.
- To track performance over time cumulatively.
- Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
 - Window Functions: SUM() OVER(), AVG() OVER()
========================================================================
*/

-- Calculate the total sales and average price per month
-- and the running total of sales over time
SELECT
order_date,
total_sales,
-- Partition for the year
--SUM(total_sales) OVER (PARTITION BY order_date ORDER BY order_date) AS running_total_sales
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
ROUND(AVG(avg_price) OVER (ORDER BY order_date), 2) AS moving_average_price
FROM
(	
SELECT
TO_CHAR(DATE_TRUNC('year', order_date), 'YYYY-MM') AS order_date, 
SUM(sales_amount) AS total_sales,
ROUND(AVG(price),2) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY TO_CHAR(DATE_TRUNC('year', order_date),'YYYY-MM')
ORDER BY
MIN(order_date)
)t
