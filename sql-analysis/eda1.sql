/** Exploratory Data Analysis
1. Database Exploration
2. Dimensions Exploration
3. Date Exploration
4. Measures Exploration
5. Magnitude
6. Ranking
**/

-- Explore All Objects in the Database
select * from information_schema.tables


-- Explore All Columns in the Database
select * from information_schema.columns
where table_name = 'dim_customers'

-- Explore All Countries our customers come from.
select distinct country from gold.dim_customers

SELECT DISTINCT category, product_name
FROM gold.dim_products
ORDER BY 1, 2;


-- Find the date of the first and last order
-- How many years of sales are available
SELECT
  MIN(order_date) AS first_order_date,
  MAX(order_date) AS last_order_date,
  EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12 +
  EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS order_range_months
FROM gold.fact_sales;


-- Find the youngest and the oldest customer
SELECT
MIN(birthdate) AS oldest_birthdate,
MAX(birthdate) AS youngest_birthdate
FROM gold.dim_customers

