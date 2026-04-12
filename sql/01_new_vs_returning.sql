-- 01_new_vs_returning.sql
-- <Objective>
-- Compare user count, order volume, revenue, and average item price
-- between new and returning users.

-- <Data Source>
-- bigquery-public-data.thelook_ecommerce.orders
-- bigquery-public-data.thelook_ecommerce.order_items

WITH user_first_order AS (
  SELECT
    user_id,
    MIN(created_at) AS first_order_date
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  GROUP BY user_id
),

labeled_orders AS (
  SELECT
    o.order_id,
    o.user_id,
    o.created_at,
    CASE
      WHEN o.created_at = ufo.first_order_date THEN 'New'
      ELSE 'Returning'
    END AS user_type
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  LEFT JOIN user_first_order ufo
    ON o.user_id = ufo.user_id
)

SELECT
  lo.user_type,
  COUNT(DISTINCT lo.user_id) AS user_count,
  COUNT(DISTINCT lo.order_id) AS order_count,
  SUM(oi.sale_price) AS revenue,
  AVG(oi.sale_price) AS avg_price_per_item
FROM labeled_orders lo
LEFT JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
  ON lo.order_id = oi.order_id
GROUP BY lo.user_type
ORDER BY revenue DESC;