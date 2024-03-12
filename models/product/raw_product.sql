-- models/orders/raw/orders_model.sql

{{ config(materialized='table') }}  -- or 'table', if you prefer

SELECT 
    "ProductID" AS product_id,
    "ProductName" AS product_name,
    "Category" as category,
    "Price" as price,
    "StockQuantity" as qty_in_stock
FROM {{ source('raw', 'products') }}
