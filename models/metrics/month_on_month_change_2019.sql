WITH orders_2019 AS (
    SELECT
        PARSE_DATE('%d/%m/%Y', order_date) AS order_date,
        sales
    FROM {{ source('raw', 'orders') }}
    WHERE EXTRACT(YEAR FROM PARSE_DATE('%d/%m/%Y', order_date)) = 2019
),

monthly_sales AS (
    SELECT
        EXTRACT(MONTH FROM order_date) AS month,
        SUM(sales) AS total_sales
    FROM orders_2019
    GROUP BY 1
),

mom_change AS (
    SELECT
        month,
        total_sales,
        LAG(total_sales) OVER (ORDER BY month) AS prev_month_sales,
        SAFE_DIVIDE(total_sales - LAG(total_sales) OVER (ORDER BY month),
                    LAG(total_sales) OVER (ORDER BY month)) AS mom_change_pct
    FROM monthly_sales
)

SELECT *
FROM mom_change
ORDER BY month