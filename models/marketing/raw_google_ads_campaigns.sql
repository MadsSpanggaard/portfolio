
{{ config(materialized='table') }} 

SELECT 
    "CampaignID" AS campaign_id,
    "ProductID" AS product_id,
    "Date"::date AS date,
    "Impressions" AS impressions,
    "Clicks" AS clicks,
    "CTR" AS ctr,
    "CPC" AS cpc,
    "TotalSpend" AS total_spend
FROM
     {{ source('raw', 'google_ads_campaigns') }}
