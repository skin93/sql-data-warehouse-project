/*
==========================================
Customer Report
==========================================

Purpose:
	This report consolidate key customer metrics and behaviors

Highlights:
	1. Gathers essentials fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, REgular, New) and age groups.
	3. Aggregates customer-level metrics:
		- total orders
		- totals sales
		- total quantity purchased
		- total products
		- lifespan (in months)
	4. Calculates valuable KPIs
		- recency (months since last order)
		- average order value
		- average monthly spend

==========================================
*/

-- ==========================================
-- Create Report: gold.report_customers
-- ==========================================

IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
	DROP VIEW gold.report_customers
GO

CREATE VIEW gold.report_customers AS

WITH base_query AS (
/*
------------------------------------------
1) Base Query: Retrieves core columns from tables
------------------------------------------
*/
	SELECT 
		f.order_number,
		f.product_key,
		f.order_date,
		f.sales_amount,
		f.quantity,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
		DATEDIFF(year, c.birthdate, GETDATE()) AS customer_age
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_customers AS c
	ON f.customer_key = c.customer_key
	WHERE order_date IS NOT NULL
), 

/*
------------------------------------------
2) Customer Aggregation: Summarizes key metrics at the customer level
------------------------------------------
*/

customer_aggregation AS (
	SELECT
	customer_key,
	customer_number,
	customer_name,
	customer_age,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY
	customer_key,
	customer_number,
	customer_name,
	customer_age
)

/*
------------------------------------------
3) Final Query: Combine all customer results into one output
------------------------------------------
*/

SELECT
	customer_key,
	customer_number,
	customer_name,
	customer_age,
	CASE
		WHEN customer_age < 20 THEN 'Under 20'
		WHEN customer_age BETWEEN 20 AND 29 THEN '20-29'
		WHEN customer_age BETWEEN 30 AND 39 THEN '30-39'
		WHEN customer_age BETWEEN 40 AND 49 THEN '40-49'
		ELSE '50 and above'
	END age_group,
	CASE
		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'REgular'
		ELSE 'New'
	END customer_segment,
	last_order_date,
	DATEDIFF(month, last_order_date, GETDATE()) AS recency,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	lifespan,
	-- Compute average order value (AVO)
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END avg_order_value,
	-- Compute average monthly spend
	CASE 
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END avg_monthly_spend
FROM customer_aggregation