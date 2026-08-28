SELECT
  oi.order_id,
  oi.user_id,
  DATE(oi.created_at) AS order_date,
  oi.sale_price,
  oi.status,
  CASE WHEN oi.status IN ('Cancelled','Returned') THEN 'Lost' ELSE 'Healthy' END AS revenue_type,
  p.category,
  p.brand,
  p.name AS product_name,
  u.country,
  u.gender,
  u.age,
  u.traffic_source
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
  ON oi.product_id = p.id
JOIN `bigquery-public-data.thelook_ecommerce.users` AS u
  ON oi.user_id = u.id
