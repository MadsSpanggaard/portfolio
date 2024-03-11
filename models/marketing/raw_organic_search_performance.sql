
{{ config(materialized='table') }}  -- or 'table', if you prefer

SELECT *
FROM {{ source('raw', 'organic_search_performance') }}
