/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/

-- Analyse sales performance over time
-- Quick Date Functions

SELECT 
YEAR(order_date) AS [year],
SUM(sales_amount) AS total_sales,
COUNT(order_number) AS [number of orders],
SUM(quantity) AS [quantity],
COUNT(DISTINCT customer_key) AS [number of customers]
FROM gold.fact_sales
WHERE YEAR(order_date) IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date) , SUM(sales_amount)


-- DATETRUNC

SELECT 
DATETRUNC(month , order_date) AS [DATE],
SUM(sales_amount) AS total_sales,
COUNT(order_number) AS [number of orders],
SUM(quantity) AS [quantity],
COUNT(DISTINCT customer_key) AS [number of customers]
FROM gold.fact_sales
WHERE DATETRUNC(month , order_date) IS NOT NULL
GROUP BY DATETRUNC(month , order_date)
ORDER BY DATETRUNC(month , order_date) , SUM(sales_amount)


-- FORMAT

SELECT 
FORMAT(order_date , 'dd/MM/yyyy') AS [DATE],
SUM(sales_amount) AS total_sales,
COUNT(order_number) AS [number of orders],
SUM(quantity) AS [quantity],
COUNT(DISTINCT customer_key) AS [number of customers]
FROM gold.fact_sales
WHERE FORMAT(order_date , 'dd/MM/yyyy')  IS NOT NULL
GROUP BY FORMAT(order_date , 'dd/MM/yyyy') 
ORDER BY FORMAT(order_date , 'dd/MM/yyyy')
