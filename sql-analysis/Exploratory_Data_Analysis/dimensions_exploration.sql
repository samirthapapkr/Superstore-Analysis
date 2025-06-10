/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

-- Explore All Countries our customers come from.
select distinct country from gold.dim_customers

-- Retrieve a list of unique categories, subcategories, and products
SELECT DISTINCT category, product_name
FROM gold.dim_products
ORDER BY 1, 2;

