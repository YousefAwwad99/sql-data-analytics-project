/*
===============================================================================
Customer Report
===============================================================================
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
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================
IF OBJECT_ID ('gold.customer_report' , 'V') IS NOT NULL
	DROP VIEW gold.customer_report
GO
CREATE VIEW gold.customer_report AS
WITH basic_customer_cte AS
(
	SELECT 
	c.customer_key,
	c.first_name,
	c.last_name,
	s.order_date,
	s.order_number,
	s.sales_amount,
	s.quantity,
	s.product_key,
	DATEDIFF(year , c.birthdate, GETDATE()) AS age
	FROM gold.fact_sales AS s
	LEFT JOIN gold.dim_customers AS c
	ON s.customer_key = c.customer_key
)
	, mid_customer_report AS 
	(
		SELECT 
		customer_key,
		first_name,
		last_name,
		age,
		CASE WHEN DATEDIFF(month ,MIN(order_date) ,MAX(order_date)) >= 12 AND SUM(sales_amount) > 5000 THEN 'VIP'
			 WHEN DATEDIFF(month ,MIN(order_date) ,MAX(order_date)) >= 12 AND SUM(sales_amount) <= 5000 THEN 'Regular'
			 ELSE 'New'
		END customer_segment,

		CASE WHEN age >= 0 AND age <= 20 THEN '0 - 20'
			 WHEN age > 20 AND age <= 50 THEN '21 - 50'
			 ELSE 'Over 50'
		END age_segment,

		COUNT(DISTINCT order_number) AS [number of orders],
		SUM(sales_amount) AS [total sales],
		SUM(quantity) AS [total quantity],
		COUNT(DISTINCT product_key) AS [number of products],
		DATEDIFF(month , MIN(order_date) , MAX(order_date)) AS lifespan,
		MAX(order_date) AS [last order]
	FROM basic_customer_cte
	GROUP BY customer_key,
		first_name,
		last_name,
		age
		)
	, final_customer_report AS (
	SELECT 
		customer_key,
		first_name,
		last_name,
		age,
		customer_segment,
		age_segment,
		[number of orders],
		[total sales],
		[total quantity],
		[number of products],
		lifespan,
		DATEDIFF(month , [last order] , GETDATE()) AS [recency],
		CASE WHEN [number of orders] = 0 THEN 0
			 ELSE [total sales] / [number of orders]
		END [average order value],
		CASE WHEN lifespan = 0 THEN [total sales]
			ELSE [total sales] / lifespan
		END [average monthly spend]
		FROM mid_customer_report
		)

		SELECT * FROM final_customer_report


