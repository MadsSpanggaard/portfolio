-- models/orders/raw/orders_model.sql

{{ config(materialized='view') }}  -- or 'table', if you prefer

WITH order_items as (
    SELECT 
        order_id, 
        SUM(qty) * sum(price_per_unit) as total_amount 
    FROM {{ref("raw_order_items")}}
    GROUP BY 1 
)

SELECT 
    o.id,
    o.user_id,
    o.order_date,
    o.shipping_address,
    oi.total_amount
FROM {{ref("raw_orders")}} o 
LEFT JOIN order_items oi on oi.order_id = o.id
