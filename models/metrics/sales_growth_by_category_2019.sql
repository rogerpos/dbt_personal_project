WITH orders_2019 AS (
    SELECT
        category,
        PARSE_DATE('%d/%m/%Y', order_date) AS order_date,
        sales
    FROM {{ source('raw', 'orders') }}
    WHERE EXTRACT(YEAR FROM PARSE_DATE('%d/%m/%Y', order_date)) = 2019
),

monthly_sales AS (
    SELECT
        category,
        EXTRACT(MONTH FROM order_date) AS month,
        SUM(sales) AS total_sales
    FROM orders_2019
    GROUP BY 1, 2
),

growth AS (
    SELECT
        category,
        month,
        total_sales,
        LAG(total_sales) OVER (
            PARTITION BY category ORDER BY month
        ) AS prev_month_sales,
        SAFE_DIVIDE(
            total_sales - LAG(total_sales) OVER (PARTITION BY category ORDER BY month),
            LAG(total_sales) OVER (PARTITION BY category ORDER BY month)
        ) AS monthly_growth_pct
    FROM monthly_sales
)

SELECT *
FROM growth
ORDER BY category, month
