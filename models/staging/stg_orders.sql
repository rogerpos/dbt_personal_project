{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('raw', 'orders') }}
),

renamed AS (
    SELECT
        CAST(row_id AS INTEGER) AS row_id,
        order_id,
        order_date,
        ship_date,
        customer_id,
        customer_name,
        segment,
        product_id,
        product_name,
        category,
        sub_category,
        sales,
        quantity,
        discount,
        profit,
        state_province,
        city,
        region,
        country_region
    FROM source
)

SELECT * FROM renamed
