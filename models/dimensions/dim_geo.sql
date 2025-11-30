{{ config(materialized='table') }}

SELECT DISTINCT
    state_province,
    city,
    region,
    country_region
FROM {{ ref('stg_orders') }}
