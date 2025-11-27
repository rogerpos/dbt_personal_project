{{ config(materialized='table') }}

SELECT DISTINCT
    product_id,
    product_name,
    category,
    sub_category AS subcategory
FROM {{ ref('stg_orders') }};
