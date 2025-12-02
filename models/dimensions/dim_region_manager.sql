{{ config(materialized='table') }}

SELECT DISTINCT
    region,
    regional_manager
FROM {{ ref('stg_people') }}
