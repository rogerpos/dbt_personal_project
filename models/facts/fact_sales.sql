{{ config(materialized='table') }}

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

returns AS (
    SELECT * FROM {{ ref('stg_returns') }}
),

geo AS (
    SELECT * FROM {{ ref('dim_geo') }}
),

joined AS (
    SELECT
        o.row_id,
        o.order_id,
        o.order_date,
        o.ship_date,
        o.product_id,
        o.customer_id,
        g.geo_key,
        o.sales,
        o.quantity,
        o.discount,
        o.profit,
        COALESCE(r.return_flag, 0) AS is_returned
    FROM orders o
    LEFT JOIN returns r
        ON o.order_id = r.order_id
    LEFT JOIN geo g
        ON o.state_province = g.state_province
        AND o.city = g.city
        AND o.region = g.region
        AND o.country_region = g.country_region
)

SELECT * FROM joined