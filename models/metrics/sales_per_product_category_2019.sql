{{ config(materialized='view') }}

WITH orders_2019 AS (
    SELECT
        category,
        sales
    FROM {{ source('raw', 'orders') }}
    WHERE EXTRACT(YEAR FROM PARSE_DATE('%d/%m/%Y', order_date)) = 2019
)

SELECT
    category,
    SUM(sales) AS total_sales
FROM orders_2019
GROUP BY 1
ORDER BY total_sales DESC
