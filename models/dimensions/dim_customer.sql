{{ config(materialized='table') }}

SELECT DISTINCT
    customer_id,
    customer_name,
    segment
FROM {{ ref('stg_orders') }}