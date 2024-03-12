-- models/orders/raw/orders_model.sql

{{ config(materialized='table') }}  -- or 'table', if you prefer

SELECT 
    "OrderID" as id,
    "UserID" as user_id,
    "OrderDate" as order_date,
    "ShippingAddress" as shipping_address,
    "TotalAmount" as total_amount
FROM {{ source('raw', 'orders') }}
