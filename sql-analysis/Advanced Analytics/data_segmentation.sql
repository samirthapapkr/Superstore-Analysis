/*
===============================================================
Data Segmentation Analysis
===============================================================
Purpose:
 - To group data into meaningful categories for targeted insights.
 - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
 - CASE: Defines custom segmentation logic.
 - GROUP BY: Groups data into segments.
================================================================
*/

/* Segment products into cost ranges and 
count how many products fall into each segment*/
WITH products_segment AS (
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost between 100 AND 500 THEN '100-500'
     WHEN cost between 500 AND 1000 THEN '500-1000'
     ELSE 'Above 1000'
END cost_range
FROM gold.dim_products
)
SELECT
cost_range,
COUNT(product_key) AS total_products
FROM products_segment
GROUP BY cost_range 
ORDER BY total_products DESC

/* Group customers into three segments based on their spending behaviour:
    - VIP: Customers with at least 12 months of history and spending more than $5,000.
    - Regular: Customers with at least 12 months of history but spending $5,000 or less.
    - New: Customers with a lifespan less than 12 months.
And find the total number of customer by each group.
*/
WITH customer_spending AS (
SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
(DATE_PART('year', MAX(order_date)) - DATE_PART('year', MIN(order_date))) * 12 +
  (DATE_PART('month', MAX(order_date)) - DATE_PART('month', MIN(order_date))) AS lifespan_in_months
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT
customer_segments,
COUNT(customer_key) AS total_customers
FROM (
SELECT
customer_key,
CASE WHEN lifespan_in_months >= 12 AND total_spending > 5000 THEN 'VIP'
     WHEN lifespan_in_months >= 12 AND total_spending < 5000 THEN 'REGULAR'
     ELSE 'NEW CUSTOMER'
END customer_segments
FROM customer_spending 
) t
GROUP BY customer_segments
ORDER BY total_customers DESC
