{{ config(materialized='view') }}

WITH fact AS (
    SELECT * FROM {{ ref('fact_sales') }}
),

product AS (
    SELECT * FROM {{ ref('dim_product') }}
),

date_dim AS (
    SELECT * FROM {{ ref('dim_date') }}
)

SELECT
    d.year,
    d.month,
    d.month_name,
    DATE_TRUNC(PARSE_DATE('%d/%m/%Y', f.order_date), MONTH) AS month_date,
    p.category,
    p.subcategory,
    COUNT(DISTINCT f.order_id) AS total_orders,
    SUM(f.sales) AS total_sales,
    SUM(f.quantity) AS total_quantity,
    SUM(f.profit) AS total_profit,
    AVG(f.sales) AS avg_order_value,
    SUM(f.discount) AS total_discount,
    SUM(CASE WHEN f.is_returned = 1 THEN 1 ELSE 0 END) AS returned_orders,
    COUNT(DISTINCT f.order_id) - SUM(CASE WHEN f.is_returned = 1 THEN 1 ELSE 0 END) AS successful_orders
FROM fact f
JOIN product p ON f.product_id = p.product_id
JOIN date_dim d ON PARSE_DATE('%d/%m/%Y', f.order_date) = d.date
GROUP BY 
    d.year,
    d.month,
    d.month_name,
    DATE_TRUNC(PARSE_DATE('%d/%m/%Y', f.order_date), MONTH),
    p.category,
    p.subcategory
ORDER BY 
    month_date,
    p.category,
    p.subcategory
