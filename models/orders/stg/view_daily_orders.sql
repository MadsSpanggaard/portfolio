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
    COALESCE(o.n_orders, 0) AS n_orders,
    SUM(o.total_amount) OVER(ORDER BY d.date asc) as running_total_amount, 
    SUM(o.n_orders) OVER(ORDER BY d.date asc) as running_n_orders 
    
FROM 
    {{ ref('date') }} d
LEFT JOIN orders o ON d.date = o.order_date
WHERE 
    d.date BETWEEN (SELECT MIN(order_date) FROM orders) AND (SELECT MAX(order_date) FROM orders)
ORDER BY 
    d.date
