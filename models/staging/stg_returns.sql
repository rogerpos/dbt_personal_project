{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('raw', 'returns') }}
),

renamed AS (
    SELECT DISTINCT
        order_id,
        1 AS return_flag
    FROM source
)

SELECT * FROM renamed
