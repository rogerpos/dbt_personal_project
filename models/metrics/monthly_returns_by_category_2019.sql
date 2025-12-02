-- I need to select all the orders from 2019, extract the month and category
WITH orders_2019 AS (
    SELECT
        order_id,
        category,
        EXTRACT(MONTH FROM PARSE_DATE('%d/%m/%Y', order_date)) AS month
    FROM {{ source('raw', 'orders') }}
    WHERE EXTRACT(YEAR FROM PARSE_DATE('%d/%m/%Y', order_date)) = 2019
),
-- I want to get distinct returns to avoid double counting
returns_distinct AS (
    SELECT DISTINCT order_id
    FROM {{ source('raw', 'returns') }}
)

SELECT
    o.category,
    o.month,
    COUNT(DISTINCT o.order_id) AS total_returns
FROM orders_2019 o
INNER JOIN returns_distinct r
    ON o.order_id = r.order_id
GROUP BY o.category, o.month
ORDER BY o.category, o.month
