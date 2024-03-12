
{{ config(materialized='view') }} 

SELECT 
    campaign_id,
    product_id,
    MIN(date) AS start_date, 
    MAX(date) AS end_date, 
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    AVG(ctr) AS avg_ctr,
    AVG(cpc) AS avg_cpc,
    SUM(total_spend) AS total_spend
FROM
    {{ref('raw_google_ads_campaigns')}}
GROUP BY 1,2

