-- models/orders/raw/orders_model.sql

{{ config(materialized='table') }}  -- or 'table', if you prefer

SELECT *
FROM {{ source('raw', 'products') }}
