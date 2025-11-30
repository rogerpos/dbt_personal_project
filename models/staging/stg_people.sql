{{ config(materialized="view") }}

SELECT
    Region AS region,
    `Regional Manager` AS regional_manager
FROM {{ ref('people') }}

