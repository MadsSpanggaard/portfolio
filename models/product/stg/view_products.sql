{{ config(materialized='view') }} 

SELECT 
    product_id,
    product_name,
    CASE 
        WHEN category = 'Electronix' THEN 'Electronics'
        WHEN category = 'Home&Kitchen' THEN 'Home & Kitchen'
        WHEN category = 'books' THEN 'Books' 
        ELSE category 
    END AS category,
    price,
    qty_in_stock
FROM 
    {{ ref("raw_product") }}

