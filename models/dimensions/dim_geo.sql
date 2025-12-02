{{ config(materialized='table') }}

WITH distinct_geo AS (
    SELECT DISTINCT
        state_province,
        city,
        region,
        country_region
    FROM {{ ref('stg_orders') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['country_region', 'region', 'state_province', 'city']) }} AS geo_key,
    state_province,
    city,
    region,
    country_region
FROM distinct_geo
