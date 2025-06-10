/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), EXTRACT()
===============================================================================
*/

-- Find the date of the first and last order
-- How many years of sales are available
SELECT
  MIN(order_date) AS first_order_date,
  MAX(order_date) AS last_order_date,
  EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12 +
  EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS order_range_months
FROM gold.fact_sales;


-- Find the youngest and the oldest customer based on birthdate
SELECT
MIN(birthdate) AS oldest_birthdate,
MAX(birthdate) AS youngest_birthdate
FROM gold.dim_customers;

--Find the youngest and oldest customer based on birthdate 
SELECT
MIN(birthdate) AS oldest_birthdate,
EXTRACT(YEAR FROM AGE(MIN(birthdate))) AS oldest_age,
MAX(birthdate) AS youngest_birthdate,
EXTRACT(YEAR FROM AGE(MAX(birthdate))) AS youngest_age
FROM gold.dim_customers;
