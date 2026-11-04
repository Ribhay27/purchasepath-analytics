-- PurchasePath: clean event model

-- Preview the main funnel events with user, session, device, and country fields

SELECT
    event_name,
    user_pseudo_id AS user_id,
    device.category AS device,
    geo.country AS country,

    (
        SELECT value.int_value
        FROM UNNEST(event_params)
        WHERE key = 'ga_session_id'
    ) AS session_id

FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

WHERE
    event_name IN (
        'view_item',
        'add_to_cart',
        'begin_checkout',
        'purchase'
    )

LIMIT 100;
