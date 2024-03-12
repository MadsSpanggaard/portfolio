-- models/orders/raw/orders_model.sql

{{ config(materialized='table') }}  -- or 'table', if you prefer

SELECT 
    "OrderItemID" AS id,
    "OrderID" as order_id,
    "ProductID" as product_id,
    "Quantity" as qty,
    "PricePerUnit" as price_per_unit
FROM {{ source('raw', 'order_items') }}
