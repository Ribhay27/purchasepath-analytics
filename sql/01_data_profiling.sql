-- PurchasePath: initial GA4 data profiling


-- Dataset size

SELECT
    COUNT(*) AS total_events,
    COUNT(DISTINCT user_pseudo_id) AS unique_users,
    COUNT(DISTINCT event_date) AS total_days
FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;


-- Event types and how many users triggered each one

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


-- Look at the main funnel events and the fields attached to them

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


WITH funnel_events AS (
    SELECT
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
        ARRAY_LENGTH(items) AS item_count

    FROM
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

    WHERE
        event_name IN (
            'view_item',
            'add_to_cart',
            'begin_checkout',
            'purchase'
        )
)

SELECT
    event_name,
    COUNT(*) AS total_events,
    COUNTIF(user_pseudo_id IS NULL) AS missing_user_id,
    COUNTIF(ga_session_id IS NULL) AS missing_session_id,
    COUNTIF(device_category IS NULL) AS missing_device,
    COUNTIF(country IS NULL) AS missing_country,
    COUNTIF(traffic_source IS NULL) AS missing_source,
    COUNTIF(traffic_medium IS NULL) AS missing_medium,
    COUNTIF(item_count IS NULL OR item_count = 0) AS events_without_items
FROM
    funnel_events
GROUP BY
    event_name
ORDER BY
    total_events DESC;
