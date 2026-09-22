-- validation_05_repeat_user_logic.sql
-- Repeat-order user count must match the Repeat Order user population
-- reported by the main analysis query.
-- Expected result:
-- repeat_order_users = main query Repeat Order user_count
-- min_orders_among_repeat_users >= 2

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
  COUNTIF(order_count > 1) AS repeat_order_users,
  MIN(IF(order_count > 1, order_count, NULL)) AS min_orders_among_repeat_users,
  MAX(order_count) AS max_orders_per_user
FROM user_order_counts;
