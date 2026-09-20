/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/

-- Which categories contribute the most to overall sales?

SELECT 
p.category,
SUM(s.sales_amount) AS [total sales]
FROM gold.dim_products AS p
LEFT JOIN gold.fact_sales AS s
ON p.product_key = s.product_key
WHERE category IS NOT NULL
GROUP BY p.category
ORDER BY SUM(s.sales_amount) DESC


