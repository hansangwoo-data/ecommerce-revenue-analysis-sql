-- validation_03_first_orders_equal_users.sql
-- First-order count must equal the number of eligible users.
-- Expected result: difference = 0.

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
  COUNT(DISTINCT user_id) AS eligible_users,
  COUNTIF(order_sequence = 1) AS first_orders,
  COUNT(DISTINCT user_id)
    - COUNTIF(order_sequence = 1) AS difference
FROM ranked_orders;
