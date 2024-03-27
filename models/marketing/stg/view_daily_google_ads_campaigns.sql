{{ config(materialized='view') }}

WITH base AS (
  SELECT
    id as campaign_product_id, 
    campaign_id,
    product_id,
    date,
    impressions,
    clicks,
    ctr,
    cpc,
    total_amount,
    CASE
        WHEN EXTRACT(DOW FROM date) = 0 THEN 'Sunday'
        WHEN EXTRACT(DOW FROM date) = 1 THEN 'Monday'
        WHEN EXTRACT(DOW FROM date) = 2 THEN 'Tuesday'
        WHEN EXTRACT(DOW FROM date) = 3 THEN 'Wednesday'
        WHEN EXTRACT(DOW FROM date) = 4 THEN 'Thursday'
        WHEN EXTRACT(DOW FROM date) = 5 THEN 'Friday'
        WHEN EXTRACT(DOW FROM date) = 6 THEN 'Saturday'
    END AS day_of_week, 
    SUM(impressions) OVER(PARTITION BY campaign_id, product_id ORDER BY date) AS running_impressions,
    SUM(clicks) OVER(PARTITION BY campaign_id, product_id ORDER BY date) AS running_clicks,
    (SUM(total_amount) OVER(PARTITION BY campaign_id, product_id ORDER BY date))::DECIMAL(10,2) AS running_total_amount,
    (AVG(ctr) OVER(PARTITION BY campaign_id, product_id ORDER BY date))::DECIMAL(10,2) as running_avg_ctr, 
    (AVG(cpc) OVER(PARTITION BY campaign_id, product_id ORDER BY date))::DECIMAL(10,2) AS running_avg_cpc,
    (SUM(total_amount) OVER(PARTITION BY campaign_id, product_id ORDER BY date) / NULLIF(SUM(impressions) OVER(PARTITION BY campaign_id, product_id ORDER BY date), 0))::DECIMAL(10,2) AS running_avg_cpi,
    LAG(clicks, 1) OVER(PARTITION BY campaign_id, product_id ORDER BY date) AS previous_day_clicks,
    LAG(impressions, 1) OVER(PARTITION BY campaign_id, product_id ORDER BY date) AS previous_day_impressions,
    LAG(total_amount, 1) OVER(PARTITION BY campaign_id, product_id ORDER BY date)::DECIMAL(10,2) AS previous_day_total_amount,
    clicks - LAG(clicks, 1) OVER(PARTITION BY campaign_id, product_id ORDER BY date) AS day_to_day_click_difference,
    impressions - LAG(impressions, 1) OVER(PARTITION BY campaign_id, product_id ORDER BY date) AS day_to_day_impression_difference,
    total_amount - LAG(total_amount, 1) OVER(PARTITION BY campaign_id, product_id ORDER BY date)::DECIMAL(10,2) AS day_to_day_spend_difference
  FROM
    {{ref('raw_google_ads_campaigns')}}
)


SELECT
    b.campaign_product_id, 
    b.campaign_id,
    b.product_id,
    b.date,
    b.impressions,
    b.clicks,
    b.ctr,
    b.cpc,
    b.total_amount,
    b.day_of_week,
    b.running_impressions,
    b.running_clicks,
    b.running_total_amount,
    b.running_avg_ctr,
    b.running_avg_cpc,
    b.running_avg_cpi,
    b.previous_day_clicks,
    b.previous_day_impressions,
    b.previous_day_total_amount,
    b.day_to_day_click_difference,
    b.day_to_day_impression_difference,
    b.day_to_day_spend_difference
FROM base b
ORDER BY b.campaign_id, b.product_id, b.date

