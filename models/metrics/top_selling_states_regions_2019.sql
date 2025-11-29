{{ config(materialized='view') }}

WITH orders_2019 AS (
    SELECT
        state,
        sales_amount,
        region
    FROM {{ source('raw', 'orders') }}
    WHERE EXTRACT(YEAR FROM order_date) = 2019
),

enriched AS (
    SELECT
        o.state,
        o.region,
        p.regional_manager,
        o.sales_amount
    FROM orders_2019 o
    LEFT JOIN {{ ref('people') }} p
        ON o.region = p.region
)

SELECT
    state,
    region,
    regional_manager,
    SUM(sales_amount) AS total_sales
FROM enriched
GROUP BY 1, 2, 3
ORDER BY total_sales DESC;
