{{ config(materialized='table') }}

SELECT DISTINCT
    state,
    city,
    region,
    country_region
FROM {{ ref('stg_orders') }};
