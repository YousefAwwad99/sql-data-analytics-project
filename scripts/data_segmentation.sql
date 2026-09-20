/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/*Segment products into cost ranges and 
count how many products fall into each segment*/
WITH segment_costs AS
(
SELECT 
product_name,
cost,
CASE WHEN cost >=0 AND cost <= 500 THEN 'Low'
	 WHEN cost > 500 AND cost <= 1000 THEN 'Medium'
	 ELSE 'High'
END segment
FROM gold.dim_products
)

SELECT 
segment,
COUNT(product_name) AS [number of products]
FROM segment_costs
GROUP BY segment
ORDER BY COUNT(product_name) DESC



/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/
WITH customer_report AS 
(
SELECT 
c.customer_key,
c.first_name,
c.last_name,
SUM(s.sales_amount) AS [total sales],
MIN(order_date) AS [start_date],
MAX(order_date) AS [end_date],
DATEDIFF(month ,MIN(order_date) ,MAX(order_date)) [number of months],
CASE WHEN DATEDIFF(month ,MIN(order_date) ,MAX(order_date)) >= 12 AND SUM(s.sales_amount) > 5000 THEN 'VIP'
	 WHEN DATEDIFF(month ,MIN(order_date) ,MAX(order_date)) >= 12 AND SUM(s.sales_amount) <= 5000 THEN 'Regular'
	 ELSE 'New'
END customer_segment

FROM gold.dim_customers AS c
LEFT JOIN gold.fact_sales AS s
ON s.customer_key = c.customer_key
GROUP BY c.customer_key,
c.first_name,
c.last_name
)

SELECT 
customer_segment,
COUNT(customer_key) AS [number of customers]
FROM customer_report
GROUP BY customer_segment
ORDER BY COUNT(customer_key) DESC
