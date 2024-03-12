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
    SPLIT_PART(o.shipping_address, ', ', 1) AS address,
    SPLIT_PART(o.shipping_address, ', ', 2) AS city,
    SPLIT_PART(o.shipping_address, ', ', 3) AS zip,
    SPLIT_PART(o.shipping_address, ', ', 4) AS country,
    o.shipping_address,
    oi.total_amount
FROM {{ref("raw_orders")}} o 
LEFT JOIN order_items oi on oi.order_id = o.id
