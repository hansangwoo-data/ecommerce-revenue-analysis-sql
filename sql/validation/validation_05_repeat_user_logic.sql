-- validation_05_repeat_user_logic.sql
-- Sanity check: users with repeat orders must have more than one eligible order.
-- The number of rows returned equals the repeat-order user population.

WITH eligible_orders AS (
  SELECT
    order_id,
    user_id,
    created_at
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status = 'Complete'
),

user_order_counts AS (
  SELECT
    user_id,
    COUNT(DISTINCT order_id) AS order_count
  FROM eligible_orders
  GROUP BY user_id
)

SELECT
  user_id,
  order_count
FROM user_order_counts
WHERE order_count > 1
ORDER BY order_count DESC, user_id;
