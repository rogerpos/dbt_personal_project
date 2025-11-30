{{ config(materialized='table') }}

WITH dates AS (

    SELECT
        day AS date,
        EXTRACT(YEAR FROM day) AS year,
        EXTRACT(MONTH FROM day) AS month,
        FORMAT_DATE('%B', day) AS month_name,
        EXTRACT(QUARTER FROM day) AS quarter,
        EXTRACT(WEEK FROM day) AS week,
        EXTRACT(DAY FROM day) AS day_of_month,
        CASE WHEN day = DATE_TRUNC(day, MONTH) + INTERVAL 1 MONTH - INTERVAL 1 DAY
             THEN TRUE ELSE FALSE END AS is_month_end
    FROM UNNEST(
        GENERATE_DATE_ARRAY('2018-01-01', '2025-12-31', INTERVAL 1 DAY)
    ) AS day
)

SELECT * FROM dates
