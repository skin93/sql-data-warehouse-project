-- database exploration

SELECT * FROM INFORMATION_SCHEMA.TABLES

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'

-- dimensions exploration

SELECT DISTINCT country FROM gold.dim_customers

SELECT DISTINCT category, subcategory, product_number FROM gold.dim_products
ORDER BY 1,2,3

-- date explorations

SELECT 
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales 


SELECT 
	MIN(birthdate) AS oldest_birthdate,
	DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldest_age,
	MAX(birthdate) AS youngest_birthdate,
	DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers

-- measures explorations

SELECT 
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales

SELECT 
    SUM(quantity) AS total_quantity,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales

SELECT 
    AVG(price) AS avf_price
FROM gold.fact_sales

SELECT 
    COUNT(DISTINCT(order_number)) AS total_orders
FROM gold.fact_sales

SELECT 
    COUNT(product_key) AS total_products
FROM gold.dim_products

SELECT 
    COUNT(DISTINCT(product_key)) AS total_products
FROM gold.dim_products

SELECT 
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers

SELECT 
    COUNT(DISTINCT(customer_key)) AS total_customers
FROM gold.fact_sales

-- report that shows all key metrics of the business

SELECT
    'Total Sales' as measure_name,
    SUM(sales_amount) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT
    'Total Quantity',
    SUM(quantity)
FROM gold.fact_sales
UNION ALL
SELECT
    'Average Price',
    AVG(price)
FROM gold.fact_sales
UNION ALL
SELECT
    'Total Orders', 
    COUNT(DISTINCT(order_number)) 
FROM gold.fact_sales
UNION ALL
SELECT
    'Total Products',
    COUNT(DISTINCT(product_key))
FROM gold.dim_products
UNION ALL
SELECT
    'Total Customers',
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers

-- magnitude analysis

SELECT
	country,
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY 2 DESC

SELECT
	gender,
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY 2 DESC

SELECT
	category,
	COUNT(DISTINCT(product_key)) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY 2 DESC

SELECT
	category,
	AVG(cost) as average_cost
FROM gold.dim_products
GROUP BY category
ORDER BY 2 DESC

SELECT 
	p.category,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY 2 DESC

SELECT 
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON c.customer_key = f.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY 4 DESC

SELECT 
	c.country,
	SUM(f.quantity) AS total_sold_items
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY 2 DESC

-- ranking analysis

SELECT TOP 5
	p.product_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY 2 DESC

SELECT TOP 5
	p.product_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY 2 ASC

SELECT TOP 5
	p.subcategory,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON p.product_key = f.product_key
GROUP BY p.subcategory
ORDER BY 2 DESC

SELECT TOP 5
	p.subcategory,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON p.product_key = f.product_key
GROUP BY p.subcategory
ORDER BY 2 ASC

SELECT * 
FROM (
	SELECT
		p.product_name,
		SUM(f.sales_amount) AS total_revenue,
		RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
	ON p.product_key = f.product_key
	GROUP BY p.product_name
	) t
WHERE rank_products < 5

SELECT TOP 10
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON c.customer_key = f.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY 4 DESC

SELECT TOP 3
	c.customer_key,
	c.first_name,
	c.last_name,
	COUNT(DISTINCT(f.order_number)) AS total_orders
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON c.customer_key = f.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY 4 ASC
