
WITH orders_2019 AS (
    SELECT
        state_province,
        sales,
        region
    FROM {{ source('raw', 'orders') }}
    WHERE EXTRACT(YEAR FROM PARSE_DATE('%d/%m/%Y', order_date)) = 2019
),

enriched AS (
    SELECT
        o.state_province,
        o.Region as region,
        p.`Regional Manager` as regional_manager,
        o.sales
    FROM orders_2019 AS o
    LEFT JOIN {{ ref('people') }} AS p
        ON o.Region = p.Region
)

SELECT
    state_province,
    region,
    regional_manager,
    SUM(sales) AS total_sales
FROM enriched
GROUP BY 1, 2, 3
ORDER BY total_sales DESC
