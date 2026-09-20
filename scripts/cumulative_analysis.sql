/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/


-- Calculate the total sales per month 
-- and the running total of sales over time 
SELECT *,
SUM([total sales]) OVER(ORDER BY [date] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [running sum]
FROM(
		SELECT
		DATETRUNC(month,order_date) AS [date],
		SUM(sales_amount)  AS [total sales]
		FROM gold.fact_sales
		WHERE DATETRUNC(month,order_date) IS NOT NULL
		GROUP BY DATETRUNC(month,order_date)
	)T
