
{{ config(materialized='table') }}  -- or 'table', if you prefer

SELECT 
    "CampaignID" AS campaign_id,
    "ProductID" AS product_id,
    "StartDate" AS start_date,
    "EndDate" AS end_date,
    "Impressions" AS impressions,
    "Clicks" AS clicks,
    "CTR" AS ctr,
    "CPC" AS cpc,
    "TotalSpend" AS total_spend
FROM {{ source('raw', 'google_ads_campaigns') }}
