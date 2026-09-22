-- 01_first_vs_repeat_orders.sql
-- <Objective>
-- Compare first-order and repeat-order behavior at the order level.
--
-- <Definition>
-- First Order  = the first eligible order for each user
-- Repeat Order = any subsequent eligible order for the same user
--
-- <Scope>
-- Only completed orders are included in the analysis.
--
-- <Data Source>
-- bigquery-public-data.thelook_ecommerce.orders
-- bigquery-public-data.thelook_ecommerce.order_items

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
    created_at,
    ROW_NUMBER() OVER (
      PARTITION BY user_id
      ORDER BY created_at, order_id
    ) AS order_sequence
  FROM eligible_orders
),

labeled_orders AS (
  SELECT
    order_id,
    user_id,
    created_at,
    CASE
      WHEN order_sequence = 1 THEN 'First Order'
      ELSE 'Repeat Order'
    END AS order_stage
  FROM ranked_orders
),

order_metrics AS (
  SELECT
    lo.order_id,
    lo.user_id,
    lo.order_stage,
    COUNT(*) AS item_count,
    SUM(oi.sale_price) AS order_value
  FROM labeled_orders lo
  INNER JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON lo.order_id = oi.order_id
  GROUP BY
    lo.order_id,
    lo.user_id,
    lo.order_stage
)

SELECT
  order_stage,
  COUNT(DISTINCT user_id) AS user_count,
  COUNT(DISTINCT order_id) AS order_count,
  SUM(item_count) AS item_count,
  SUM(order_value) AS gross_sales,
  SAFE_DIVIDE(
    SUM(order_value),
    COUNT(DISTINCT order_id)
  ) AS avg_order_value,
  SAFE_DIVIDE(
    SUM(item_count),
    COUNT(DISTINCT order_id)
  ) AS avg_items_per_order,
  SAFE_DIVIDE(
    SUM(order_value),
    SUM(item_count)
  ) AS avg_item_price
FROM order_metrics
GROUP BY order_stage
ORDER BY
  CASE order_stage
    WHEN 'First Order' THEN 1
    WHEN 'Repeat Order' THEN 2
  END;
