
{{ config(materialized='table') }}  -- or 'table', if you prefer

SELECT 
    "UserID" AS id,
    "FirstName" AS  first_name,
    "LAS tName" AS  last_name,
    "Email" AS email,
    "SignupDate" AS signup_date,
    "Address" AS address 
FROM {{ source('raw', 'users') }}
