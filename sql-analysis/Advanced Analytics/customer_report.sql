/*
=============================================================
Customer Report
=============================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
	1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) and age groups.
	3. Aggregates customer-level metrics:
       - total orders
       - total sales
	   - total quantity purchased
       - total products
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last order)
	   - average order value
       - average monthly spend
==============================================================
*/

-- ===========================================================
-- Create Report: gold.report_customers
-- ==========================================================
DROP VIEW IF EXISTS gold.report_customers;

CREATE VIEW gold.report_customers AS
/* ---------------------------------------------------------
1. Base Query: Retrieves core columns from tables
------------------------------------------------------------*/
WITH base_query AS (
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name,' ',c.last_name) AS customer_name,
EXTRACT(YEAR FROM AGE(current_date, c.birthdate)) AS age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL
), customer_aggregation AS (
	
/* -------------------------------------------------------------------
2. Customer Aggregations: Summarizes key metrics at the customer level
----------------------------------------------------------------------*/
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
(DATE_PART('year', MAX(order_date)) - DATE_PART('year', MIN(order_date))) * 12 +
  (DATE_PART('month', MAX(order_date)) - DATE_PART('month', MIN(order_date))) AS lifespan_in_months
FROM base_query
GROUP BY
customer_key,
customer_number,
customer_name,
age
)
SELECT
customer_key,
customer_number,
customer_name,
age,
CASE WHEN age < 20 THEN 'Under 20'
     WHEN age between 20 and 29 THEN '20-29'
	 WHEN age between 30 and 29 THEN '30-39'
	 WHEN age between 40 and 49 THEN  '40-49'
	 ELSE '50 and above'
END AS age_group,
total_orders,
total_sales,
-- Compute average order value (AVO)
CASE WHEN total_orders = 0 THEN 0
	  ELSE total_sales / total_orders 
END AS avg_order_value,
-- Compute average monthly spend
CASE WHEN lifespan_in_months = 0 THEN total_sales
	 ELSE total_sales / 	lifespan_in_months
END AS avg_monthly_spend,
total_quantity,
total_products,
last_order_date,
EXTRACT(MONTH FROM AGE(current_date, last_order_date)) AS recency,
CASE WHEN lifespan_in_months >= 12 AND total_sales > 5000 THEN 'VIP'
     WHEN lifespan_in_months >= 12 AND total_sales < 5000 THEN 'REGULAR'
     ELSE 'NEW CUSTOMER'
END AS customer_segments
FROM customer_aggregation
