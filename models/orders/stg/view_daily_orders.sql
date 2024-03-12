{{ config(materialized='view') }}

WITH orders AS (
    SELECT 
        order_date::date as order_date, 
        sum(total_amount) as total_amount,
        count(distinct id) as n_orders
    FROM 
        {{ ref('view_orders') }}
    GROUP BY 1
),

min_max_orders AS ( 
    SELECT 
        MIN(order_date) as min_date,
        MAX(order_date) as max_date 
    FROM orders
)

SELECT 
    d.date as order_date,
    COALESCE(o.total_amount::DECIMAL(10,2), 0) as total_amount,
    COALESCE(o.n_orders, 0) as n_orders
FROM 
    {{ ref('date') }} d
CROSS JOIN min_max_orders mmo
LEFT JOIN orders o ON d.date = o.order_date
WHERE 
    d.date >= mmo.min_date
    AND d.date <= mmo.max_date
ORDER BY 
    d.date
