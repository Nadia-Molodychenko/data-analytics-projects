-- SUBQUERY 1: sessions_info (capture the session start and all its attributes)
WITH sessions_info AS (
  SELECT
    user_pseudo_id,
    -- 1. Numeric session ID
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    
    -- 2. Unique session key
    CONCAT(user_pseudo_id, '-', CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS STRING)) AS user_session_id,
    
    -- 3. Clean landing page (without query params after ?)
    REGEXP_EXTRACT(
      (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location'),
      r'https?://[^/]+/(.+)'
    ) AS landing_page_location,
    
    -- Geography and device
    geo.country AS country,
    device.category AS device_category,
    device.language AS device_language,
    device.operating_system AS device_os,
    
    -- Marketing channels
    traffic_source.source AS source,
    traffic_source.medium AS medium,
    traffic_source.name AS campaign
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    -- Capture the exact attributes at the moment of entering the site
    event_name = 'session_start'
    AND _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
),

-- SUBQUERY 2: events (extract all events for the 7 funnel steps)
events AS (
  SELECT
    CONCAT(user_pseudo_id, '-', CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS STRING)) AS user_session_id,
    TIMESTAMP_MICROS(event_timestamp) AS event_timestamp,
    event_name
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    event_name IN (
      'session_start',
      'view_item',
      'add_to_cart',
      'begin_checkout',
      'add_shipping_info',
      'add_payment_info',
      'purchase'
    )
    AND _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
)

-- FINAL JOINING QUERY
SELECT
  s.user_pseudo_id,
  s.session_id,
  user_session_id,
  s.landing_page_location,
  s.country,
  s.device_category,
  s.device_language,
  s.device_os,
  s.source,
  s.medium,
  s.campaign,
  e.event_timestamp,
  e.event_name
FROM
  sessions_info s
LEFT JOIN
  events e USING(user_session_id)
