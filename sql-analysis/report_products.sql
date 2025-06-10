/* 
==============================================================
Product Report
==============================================================
Purpose:
 - This report consolidates key product metrics and behaviors.

Highlights:
 1. Gathers essential fields such as product name, category, subcategory and cost.
 2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
 3. Aggregates product-level metrics:
	- total orders
	- total sales
	- total quantity sold
	- total customers (unique)
	- lifespan (in months)
 4. Calculates valuable KPIs:
	- recency (months since last sale)
	- average order revenue (AOR)
	- average monthly revenue
======================================================================
*/

-- =========================================================
-- Create Report: gold.report_products
-- =========================================================
DROP VIEW IF EXISTS gold.report_products;

CREATE VIEW gold.report_products AS
WITH base_query AS (
/* ---------------------------------------------------------
1. Base Query: Retrieves core columns from fact_sales and dim_products
------------------------------------------------------------*/
SELECT
	f.order_number,
	f.order_date,
	f.customer_key,
	f.sales_amount,
	f.quantity,
	p.product_key,
	p.product_name,
	p.category,
	p.cost
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL --only consider valid sales dates
), product_aggregations AS (
/* ---------------------------------------------------------
2. Product Aggregations: Summarizes key metrics at the product level
------------------------------------------------------------*/
SELECT
	product_key,
	product_name,
	category,
	cost,
	(DATE_PART('year', MAX(order_date)) - DATE_PART('year', MIN(order_date))) * 12 +
  (DATE_PART('month', MAX(order_date)) - DATE_PART('month', MIN(order_date))) AS lifespan_in_months,
	MAX(order_date) AS last_sale_date,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	ROUND(AVG((sales_amount::numeric) / NULLIF(quantity::numeric, 0)), 1) AS avg_selling_price
	FROM base_query
	GROUP BY
	product_key,
	product_name,
	category,
	cost
)
SELECT
product_key,
product_name,
category,
cost,
last_sale_date,
EXTRACT(MONTH FROM AGE(current_date, last_sale_date)) AS recency,
CASE 
WHEN total_sales > 50000 THEN 'High-Performer'
WHEN total_sales >= 10000 THEN 'Mid-Range'
ELSE 'Low Performer'
END AS product_segment,
lifespan_in_months,
total_orders,
total_sales,
total_quantity,
total_customers,
avg_selling_price,
-- Average Order Revenue
CASE 
WHEN total_orders = 0 THEN 0
ELSE total_sales / total_orders
END as avg_order_revenue,
-- Average Monthly Revenue
CASE 
WHEN lifespan_in_months = 0 THEN total_sales
ELSE total_sales/ lifespan_in_months
END AS avg_monthly_revenue
FROM product_aggregations