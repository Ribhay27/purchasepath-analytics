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

-- ------------------------------------------------------------
-- 3. Inspect key funnel event fields
-- ------------------------------------------------------------

SELECT
    PARSE_DATE('%Y%m%d', event_date) AS event_date,
    TIMESTAMP_MICROS(event_timestamp) AS event_timestamp,
    event_name,
    user_pseudo_id,

    (
        SELECT value.int_value
        FROM UNNEST(event_params)
        WHERE key = 'ga_session_id'
    ) AS ga_session_id,

    device.category AS device_category,
    geo.country AS country,
    traffic_source.source AS traffic_source,
    traffic_source.medium AS traffic_medium,
    ecommerce.transaction_id,
    ecommerce.purchase_revenue,
    ARRAY_LENGTH(items) AS item_count,
    items[SAFE_OFFSET(0)].item_name AS first_item_name

FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

WHERE
    event_name IN (
        'view_item',
        'add_to_cart',
        'begin_checkout',
        'purchase'
    )

ORDER BY
    event_timestamp

LIMIT 100;
