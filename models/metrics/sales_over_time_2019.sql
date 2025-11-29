{{ config(materialized='view') }}

WITH orders_2019 AS (
    SELECT
        order_id,
        PARSE_DATE('%d/%m/%Y', order_date) AS order_date,
        category,
        sales,
        state_province
    FROM {{ source('raw', 'orders') }}
    WHERE EXTRACT(YEAR FROM PARSE_DATE('%d/%m/%Y', order_date)) = 2019
)

SELECT
    month,
    total_sales,
    SUM(total_sales) OVER (ORDER BY month) AS cum_sales
FROM (
    SELECT
        DATE_TRUNC(order_date, MONTH) AS month,
        SUM(sales) AS total_sales
    FROM orders_2019
    GROUP BY 1
)
ORDER BY 1