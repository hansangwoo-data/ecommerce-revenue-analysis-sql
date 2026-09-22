-- validation_01_order_sequence.sql
-- Every eligible user must have exactly one First Order.
-- Expected result: 0 rows.

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
  user_id,
  COUNTIF(order_sequence = 1) AS first_order_count
FROM ranked_orders
GROUP BY user_id
HAVING first_order_count != 1;
