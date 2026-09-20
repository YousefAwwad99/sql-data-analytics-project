/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/


/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */
SELECT *,
LAG([year]) OVER(PARTITION BY product_name ORDER BY product_name , [year] ) AS [pre year],
LAG([total sales]) OVER(PARTITION BY product_name ORDER BY product_name , [year]) AS [pre sales],
AVG([total sales]) OVER(PARTITION BY product_name) AS [avg_product],
CASE WHEN [total sales] >  AVG([total sales]) OVER(PARTITION BY product_name) THEN 'Above Avg'
	 WHEN [total sales] =  AVG([total sales]) OVER(PARTITION BY product_name) THEN 'Equal'
	 ELSE 'Less Avg'
END [compar with avg]
FROM(
SELECT
YEAR(s.order_date) AS [year],
p.product_name,
SUM(s.sales_amount) AS [total sales]
FROM gold.dim_products AS p
LEFT JOIN gold.fact_sales AS s
ON s.product_key = p.product_key
WHERE YEAR(s.order_date) IS NOT NULL
GROUP BY YEAR(s.order_date) , product_name
)T

