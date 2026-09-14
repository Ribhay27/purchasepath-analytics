-- 1. Dataset size and coverage

SELECT
    COUNT(*) AS total_events,
    COUNT(DISTINCT user_pseudo_id) AS unique_users,
    COUNT(DISTINCT event_date) AS total_days
FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;


-- 2. Event distribution

SELECT
    event_name,
    COUNT(*) AS event_count,
    COUNT(DISTINCT user_pseudo_id) AS unique_users
FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
GROUP BY
    event_name
ORDER BY
    event_count DESC;
