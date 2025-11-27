{{ config(materialized='table') }}

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

returns AS (
    SELECT * FROM {{ ref('stg_returns') }}
),

people AS (
    SELECT * FROM {{ ref('stg_people') }}
),

joined AS (
    SELECT
        o.row_id,
        o.order_id,
        o.order_date,
        o.ship_date,
        o.product_id,
        o.customer_id,
        o.state,
        o.city,
        o.region,
        o.country_region,
        o.sales,
        o.quantity,
        o.discount,
        o.profit,
        COALESCE(r.return_flag, 0) AS return_flag,
        p.regional_manager
    FROM orders o
    LEFT JOIN returns r
        ON o.order_id = r.order_id
    LEFT JOIN people p
        ON o.region = p.region
)

SELECT * FROM joined;