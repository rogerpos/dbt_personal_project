{{ config(materialized='view') }}

WITH orders_2019 AS (
    SELECT
        order_id,
        order_date,
        product_category,
        sales_amount,
        state
    FROM {{ source('raw', 'orders') }}
    WHERE EXTRACT(YEAR FROM order_date) = 2019
)

SELECT
    DATE_TRUNC(order_date, MONTH) AS month,
    SUM(sales_amount) AS total_sales
FROM orders_2019
GROUP BY 1
ORDER BY 1;