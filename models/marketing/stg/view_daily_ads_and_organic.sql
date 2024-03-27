{{ config(materialized='view') }}

WITH google_ads AS (
  SELECT
    campaign_id,
    product_id,
    date,
    SUM(impressions) AS ad_impressions,
    SUM(total_amount) AS total_amount, 
    SUM(clicks) AS ad_clicks,
    AVG(ctr) AS ad_ctr
  FROM {{ref('raw_google_ads_campaigns')}}
  GROUP BY campaign_id, product_id, date
),
organic_search AS (
  SELECT
    product_id,
    date,
    SUM(impressions) AS organic_impressions,
    SUM(clicks) AS organic_clicks,
    AVG(ctr) AS organic_ctr
  FROM {{ref('raw_organic_search_performance')}}
  GROUP BY product_id, date
),
date_dimension AS (
  SELECT
    date,
    day_name,
    month_name,
    is_weekday
  FROM {{ref('date')}}
),
combined_data AS (
  SELECT
    d.date,
    d.day_name,
    d.month_name,
    d.is_weekday,
    g.product_id AS g_product_id,
    g.ad_impressions,
    g.ad_clicks,
    g.ad_ctr,
    o.product_id AS o_product_id,
    o.organic_impressions,
    o.organic_clicks,
    o.organic_ctr,
    g.total_amount
  FROM date_dimension d
  LEFT JOIN google_ads g ON d.date = g.date
  LEFT JOIN organic_search o ON d.date = o.date AND g.product_id = o.product_id
  GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
  HAVING d.date >= min(o.date) and d.date <= now()::date 

)
SELECT
    c.date,
    c.day_name,
    c.month_name,
    c.is_weekday,
    COALESCE(c.g_product_id, c.o_product_id) AS product_id,
    COALESCE(c.ad_impressions, 0) AS ad_impressions,
    COALESCE(c.ad_clicks, 0) AS ad_clicks,
    COALESCE(c.ad_ctr, 0) AS ad_ctr,
    COALESCE(c.organic_impressions, 0) AS organic_impressions,
    COALESCE(c.organic_clicks, 0) AS organic_clicks,
    COALESCE(c.organic_ctr, 0) AS organic_ctr,
    COALESCE(c.total_amount, 0) AS total_amount, 
    COALESCE(SUM(c.total_amount) OVER(ORDER BY c.date), 0) as running_total_cost,
    COALESCE(SUM(c.ad_clicks) OVER( ORDER BY c.date), 0) as running_ad_click,
    COALESCE(SUM(c.organic_clicks) OVER(ORDER BY c.date), 0) as running_org_clicks,
    COALESCE(SUM(c.ad_impressions) OVER(ORDER BY c.date), 0) as running_ad_impressions,
    COALESCE(SUM(c.organic_impressions) OVER(ORDER BY c.date), 0) as running_organic_impressions
FROM combined_data c
ORDER BY c.date, COALESCE(c.g_product_id, c.o_product_id)
