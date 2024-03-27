
{{ config(materialized='table') }} 

SELECT
    CONCAT("CampaignID", "ProductID", p.product_name) as id, 
    "CampaignID" AS campaign_id,
    "ProductID" AS product_id,
    "Date"::date AS date,
    "Impressions" AS impressions,
    "Clicks" AS clicks,
    "CTR" AS ctr,
    "CPC" AS cpc,
    "TotalSpend" AS total_amount
FROM
     {{ source('raw', 'google_ads_campaigns') }} g
LEFT JOIN {{ref("view_products")}} p on p.product_id = g."ProductID"