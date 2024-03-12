
{{ config(materialized='table') }}  

SELECT 
    "ProductID" AS product_id,
    "Date"::date AS date,
    "Impressions" AS impressions,
    "Clicks" AS clicks,
    "CTR" AS ctr,
    "AveragePosition" AS average_position
FROM 
    {{ source('raw', 'organic_search_performance') }}
