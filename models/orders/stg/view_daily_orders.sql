{{ config(materialized='view') }}

WITH orders AS (
    SELECT 
        order_date::date AS order_date, 
        SUM(total_amount) AS total_amount,
        COUNT(DISTINCT id) AS n_orders
    FROM 
        {{ ref('view_orders') }}
    GROUP BY order_date
),
monthly_totals AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(total_amount) AS total_amount,
        COUNT(*) AS n_orders
    FROM orders
    GROUP BY 1
),
prev_month_values AS (
    SELECT
        month,
        LAG(total_amount, 1) OVER (ORDER BY month) AS previous_month_amount,
        LAG(n_orders, 1) OVER (ORDER BY month) AS previous_month_orders
    FROM monthly_totals
)

SELECT
    d.date AS order_date,
    EXTRACT(year FROM d.date) AS year,
    EXTRACT(month FROM d.date) AS month,
    EXTRACT(week FROM d.date) AS week_of_year,
    CASE WHEN EXTRACT(isodow FROM d.date) < 6 THEN TRUE ELSE FALSE END AS is_weekday,
    COALESCE(o.total_amount, 0)::DECIMAL(10,2) AS total_amount,
    COALESCE(o.n_orders, 0) AS n_orders,
    pm.previous_month_amount,
    pm.previous_month_orders
FROM 
    {{ ref('date') }} d
LEFT JOIN orders o ON d.date = o.order_date
LEFT JOIN prev_month_values pm ON DATE_TRUNC('month', d.date) = pm.month
WHERE 
    d.date BETWEEN (SELECT MIN(order_date) FROM orders) AND (SELECT MAX(order_date) FROM orders)
ORDER BY 
    d.date
