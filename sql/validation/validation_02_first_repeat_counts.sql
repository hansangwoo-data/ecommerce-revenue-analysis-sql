-- validation_02_first_repeat_counts.sql
-- First + repeat orders must equal total eligible orders.
-- Expected result: total_orders = classified_orders.

WITH eligible_orders AS (
  SELECT
    order_id,
    user_id,
    created_at
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status = 'Complete'
),

ranked_orders AS (
  SELECT
    order_id,
    user_id,
    ROW_NUMBER() OVER (
      PARTITION BY user_id
      ORDER BY created_at, order_id
    ) AS order_sequence
  FROM eligible_orders
)

SELECT
  COUNT(*) AS total_orders,
  COUNTIF(order_sequence = 1) AS first_orders,
  COUNTIF(order_sequence > 1) AS repeat_orders,
  COUNTIF(order_sequence = 1)
    + COUNTIF(order_sequence > 1) AS classified_orders
FROM ranked_orders;
