WITH orders_clean AS (
    SELECT
        order_id,
        category,
        PARSE_DATE('%d/%m/%Y', order_date) AS order_date
    FROM {{ source('raw', 'orders') }}
),

all_categories AS (
    SELECT DISTINCT category
    FROM orders_clean
    WHERE EXTRACT(YEAR FROM order_date) = 2019
),

all_months AS (
    SELECT month
    FROM UNNEST(GENERATE_ARRAY(1, 12)) AS month
),

category_month_combinations AS (
    SELECT 
        c.category,
        m.month
    FROM all_categories c
    CROSS JOIN all_months m
),

returns_2019 AS (
    SELECT
        r.order_id,
        o.category,
        EXTRACT(MONTH FROM o.order_date) AS month
    FROM {{ source('raw', 'returns') }} r
    LEFT JOIN orders_clean o
        ON r.order_id = o.order_id
    WHERE EXTRACT(YEAR FROM o.order_date) = 2019
),

monthly_returns AS (
    SELECT
        category,
        month,
        COUNT(*) AS total_returns
    FROM returns_2019
    GROUP BY 1, 2
)

SELECT 
    cmc.category,
    cmc.month,
    COALESCE(mr.total_returns, 0) AS total_returns
FROM category_month_combinations cmc
LEFT JOIN monthly_returns mr
    ON cmc.category = mr.category
    AND cmc.month = mr.month
ORDER BY cmc.category, cmc.month
