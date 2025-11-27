{{ config(materialized="view") }}

SELECT
    region,
    regional_manager
FROM {{ ref('people') }};

