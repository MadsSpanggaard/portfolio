{{ config(materialized='view') }}

WITH base AS (
  SELECT
    osp.product_id,
    osp.date,
    osp.impressions,
    osp.clicks,
    osp.ctr,
    osp.average_position,
    CASE
        WHEN EXTRACT(DOW FROM osp.date) = 0 THEN 'Sunday'
        WHEN EXTRACT(DOW FROM osp.date) = 1 THEN 'Monday'
        WHEN EXTRACT(DOW FROM osp.date) = 2 THEN 'Tuesday'
        WHEN EXTRACT(DOW FROM osp.date) = 3 THEN 'Wednesday'
        WHEN EXTRACT(DOW FROM osp.date) = 4 THEN 'Thursday'
        WHEN EXTRACT(DOW FROM osp.date) = 5 THEN 'Friday'
        WHEN EXTRACT(DOW FROM osp.date) = 6 THEN 'Saturday'
    END AS day_of_week,
    LAG(osp.clicks, 1) OVER(PARTITION BY osp.product_id ORDER BY osp.date) AS previous_day_clicks,
    LAG(osp.impressions, 1) OVER(PARTITION BY osp.product_id ORDER BY osp.date) AS previous_day_impressions,
    osp.clicks - LAG(osp.clicks, 1) OVER(PARTITION BY osp.product_id ORDER BY osp.date) AS day_to_day_click_difference,
    osp.impressions - LAG(osp.impressions, 1) OVER(PARTITION BY osp.product_id ORDER BY osp.date) AS day_to_day_impression_difference
  FROM
    {{ref('raw_organic_search_performance')}} osp
  LEFT JOIN
    {{ref('date')}} dd ON osp.date = dd.date
),

day_of_week_analysis AS (
  SELECT
    day_of_week,
    AVG(clicks) AS avg_clicks_per_day,
    AVG(impressions) AS avg_impressions_per_day
  FROM base
  GROUP BY day_of_week
)

SELECT
  b.*,
  d.avg_clicks_per_day,
  d.avg_impressions_per_day
FROM base b
LEFT JOIN day_of_week_analysis d ON b.day_of_week = d.day_of_week
ORDER BY b.product_id, b.date