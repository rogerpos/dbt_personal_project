{{ config(materialized='view') }}

WITH orders_2019 AS (
    SELECT
        product_category,
        sales_amount
    FROM {{ source('raw', 'orders') }}
    WHERE EXTRACT(YEAR FROM order_date) = 2019
)

SELECT
    product_category,
    SUM(sales_amount) AS total_sales
FROM orders_2019
GROUP BY 1
ORDER BY total_sales DESC;
