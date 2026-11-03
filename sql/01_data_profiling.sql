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


-- Check purchase and revenue fields

SELECT
    COUNT(*) AS purchase_events,
    COUNT(DISTINCT user_pseudo_id) AS purchasers,

    COUNTIF(
        ecommerce.transaction_id IS NULL
        OR ecommerce.transaction_id = ''
    ) AS missing_transaction_id,

    COUNT(DISTINCT ecommerce.transaction_id) AS unique_transaction_ids,

    COUNTIF(
        ecommerce.purchase_revenue IS NULL
    ) AS missing_purchase_revenue,

    COUNTIF(
        ecommerce.purchase_revenue <= 0
    ) AS non_positive_revenue,

    ROUND(SUM(ecommerce.purchase_revenue), 2) AS total_revenue,
    ROUND(AVG(ecommerce.purchase_revenue), 2) AS avg_purchase_revenue

FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

WHERE
    event_name = 'purchase';


-- Check whether transaction IDs appear on multiple purchase events

WITH purchases AS (
    SELECT
        ecommerce.transaction_id AS transaction_id,
        ecommerce.purchase_revenue AS purchase_revenue
    FROM
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE
        event_name = 'purchase'
        AND ecommerce.transaction_id IS NOT NULL
        AND ecommerce.transaction_id != ''
)

SELECT
    transaction_id,
    COUNT(*) AS purchase_event_count,
    COUNTIF(purchase_revenue IS NULL) AS missing_revenue_events,
    ROUND(MAX(purchase_revenue), 2) AS max_revenue
FROM purchases
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY purchase_event_count DESC
LIMIT 20;


-- Check duplicate valid transaction IDs and revenue consistency

WITH purchases AS (
    SELECT
        ecommerce.transaction_id AS transaction_id,
        ecommerce.purchase_revenue AS purchase_revenue
    FROM
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE
        event_name = 'purchase'
        AND ecommerce.transaction_id IS NOT NULL
        AND ecommerce.transaction_id != ''
        AND ecommerce.transaction_id != '(not set)'
),

transactions AS (
    SELECT
        transaction_id,
        COUNT(*) AS event_count,
        COUNT(DISTINCT purchase_revenue) AS revenue_value_count,
        MIN(purchase_revenue) AS min_revenue,
        MAX(purchase_revenue) AS max_revenue
    FROM purchases
    GROUP BY transaction_id
)

SELECT
    COUNT(*) AS valid_transaction_ids,
    SUM(event_count) AS purchase_events_with_valid_id,
    COUNTIF(event_count > 1) AS duplicated_transaction_ids,
    COUNTIF(
        event_count > 1
        AND revenue_value_count > 1
    ) AS duplicates_with_different_revenue
FROM transactions;


-- Inspect device categories

SELECT
    device.category AS device_category,
    COUNT(*) AS event_count,
    COUNT(DISTINCT user_pseudo_id) AS unique_users
FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE
    event_name IN (
        'view_item',
        'add_to_cart',
        'begin_checkout',
        'purchase'
    )
GROUP BY
    device.category
ORDER BY
    event_count DESC;


-- Inspect traffic source and medium values

SELECT
    traffic_source.source AS source,
    traffic_source.medium AS medium,
    COUNT(*) AS event_count,
    COUNT(DISTINCT user_pseudo_id) AS unique_users
FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE
    event_name IN (
        'view_item',
        'add_to_cart',
        'begin_checkout',
        'purchase'
    )
GROUP BY
    source,
    medium
ORDER BY
    event_count DESC
LIMIT 30;
