/*
==========================================
Product Report
==========================================

Purpose:
	This report consolidate key product metrics and behaviors

Highlights:
	1. Gathers essentials fields such as product name, category,subcategory, and cost.
	2. Segments products by revenue to identify Hight-Performers, Mid-Range, or Low_Performers.
	3. Aggregates product-level metrics:
		- total orders
		- totals sales
		- total quantity sold
		- total customers (unique)
		- lifespan (in months)
	4. Calculates valuable KPIs
		- recency (months since last sale)
		- average order revenue (AOR)
		- average monthly revenue

==========================================
*/

-- ==========================================
-- Create Report: gold.report_products
-- ==========================================

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
	DROP VIEW gold.report_products
GO

CREATE VIEW gold.report_products AS

WITH base_query AS (
/*
------------------------------------------
1) Base Query: Retrieves core columns from tables
------------------------------------------
*/
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
	WHERE order_date IS NOT NULL
), 

/*
------------------------------------------
2) Product Aggregation: Summarizes key metrics at the product level
------------------------------------------
*/

product_aggregation AS (
	SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
	MAX(order_date) AS last_sales_date,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM base_query
GROUP BY
	product_key,
	product_name,
	category,
	subcategory,
	cost
)

/*
------------------------------------------
3) Final Query: Combine all product results into one output
------------------------------------------
*/

SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sales_date,
	DATEDIFF(month, last_sales_date, GETDATE()) AS recency_in_months,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >- 10000 THEN 'Mid-Range'
		ELSE 'Low Performer'
	END product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	-- Average Order Revenue (AOR)
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END avg_order_revenue,
	-- Compute average monthly spend
	CASE 
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END avg_monthly_revenue
FROM product_aggregation