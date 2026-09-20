/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue

       */
       IF OBJECT_ID ('gold.products_report' , 'V') IS NOT NULL
            DROP VIEW gold.products_report
       GO
       CREATE VIEW gold.products_report AS
       WITH basic_product_rep AS 
       (
           SELECT 
            p.product_key,
            p.product_name,
            p.category,
            p.subcategory,
            p.cost,
            s.sales_amount,
            s.order_date,
            s.quantity,
            s.customer_key
            FROM gold.fact_sales AS s
           LEFT JOIN gold.dim_products AS p
           ON s.product_key = p.product_key
       )
       , mid_product_report AS
       (
                SELECT 
                product_key,
                product_name,
                category,
                subcategory,
                cost,
                COUNT(order_date) AS [total orders],
                SUM(sales_amount) AS [total sales],
                SUM(quantity) AS [total quantity],
                COUNT(DISTINCT customer_key) AS [number of unique customers],
                DATEDIFF(MONTH , MIN(order_date) , MAX(order_date)) AS lifespan,
                MAX(order_date) AS last_order    
                FROM basic_product_rep
                GROUP BY  product_key,
                product_name,
                category,
                subcategory,
                cost
        )
          , final_product_report as
       (
                    SELECT
                    product_key,
                    product_name,
                    category,
                    subcategory,
                    cost,
                     CASE WHEN [total sales] >= 0 AND [total sales] <= 500 THEN 'Low-Performers'
                     WHEN [total sales] > 500 AND [total sales] <= 2000 THEN 'Mid-Range'
                     ELSE 'High-Performers'
                     END revenue_segment   ,
                    [total orders],
                    [total sales],
                    [total quantity],
                    [number of unique customers],
                    lifespan,
                    DATEDIFF(MONTH , last_order , GETDATE()) AS recency,
                    CASE WHEN [total orders] = 0 THEN 0
                         ELSE [total sales] / [total orders]
                    END [average order revenue],

                    CASE WHEN lifespan = 0 THEN [total sales]
                         ELSE [total sales] / lifespan
                    END [average monthly revenue]
            
                    FROM mid_product_report
           )

            SELECT * FROM final_product_report
