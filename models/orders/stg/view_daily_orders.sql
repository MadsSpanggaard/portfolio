{{ config(materialized='view') }}

WITH orders AS (
    SELECT 
        order_date::date AS order_date, 
        SUM(total_amount) AS total_amount,
        COUNT(*) AS n_orders
    FROM 
        {{ ref('view_orders') }}
    GROUP BY order_date
)

SELECT 
    d.date AS order_date,
    EXTRACT(year FROM d.date) AS year,
    EXTRACT(month FROM d.date) AS month,
    EXTRACT(week FROM d.date) AS week_of_year,
    is_weekday,
    COALESCE(o.total_amount, 0)::DECIMAL(10,2) AS total_amount,
    COALESCE(o.n_orders, 0) AS n_orders
FROM 
    {{ ref('date') }} d
LEFT JOIN orders o ON d.date = o.order_date
LEFT JOIN orders p ON (d.date - INTERVAL '1 month') = p.order_date
WHERE 
    d.date BETWEEN (SELECT MIN(order_date) FROM orders) AND (SELECT MAX(order_date) FROM orders)
ORDER BY 
    d.date
