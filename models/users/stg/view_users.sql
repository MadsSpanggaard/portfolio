{{ config(materialized='view') }}  

SELECT 
    id,
    first_name,
    last_name,
    email,
    signup_date,
    SPLIT_PART(u.address, ', ', 1) AS address,
    SPLIT_PART(u.address, ', ', 2) AS city,
    SPLIT_PART(u.address, ', ', 3) AS state,
    SPLIT_PART(u.address, ', ', 4) AS zip,
    SPLIT_PART(u.address, ', ', 5) AS country
FROM {{ref("raw_users")}} u
