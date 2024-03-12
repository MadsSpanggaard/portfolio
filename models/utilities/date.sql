{{ config(materialized='table') }} 

WITH date_series AS (
    SELECT generate_series(
        DATE_TRUNC('day', CURRENT_DATE) - INTERVAL '2 years',
        CURRENT_DATE,
        '1 day'::interval
    ) AS date
),
date_parts AS (
    SELECT
        date,
        EXTRACT(year FROM date) AS year,
        EXTRACT(month FROM date) AS month,
        EXTRACT(day FROM date) AS day,
        EXTRACT(doy FROM date) AS day_of_year,
        EXTRACT(week FROM date) AS week_of_year,
        EXTRACT(isodow FROM date) AS day_of_week_iso,
        EXTRACT(quarter FROM date) AS quarter,
        TO_CHAR(date, 'Day') AS day_name,
        TO_CHAR(date, 'Month') AS month_name,
        CASE 
            WHEN EXTRACT(isodow FROM date) IN (6, 7) THEN FALSE 
            ELSE TRUE 
        END AS is_weekday
    FROM date_series
)
SELECT * FROM date_parts
