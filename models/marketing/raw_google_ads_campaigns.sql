
{{ config(materialized='table') }}  -- or 'table', if you prefer

SELECT *
FROM {{ source('raw', 'google_ads_campaigns') }}
