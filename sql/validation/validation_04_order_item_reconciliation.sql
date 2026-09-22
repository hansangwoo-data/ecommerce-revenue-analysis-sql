-- validation_04_order_item_reconciliation.sql
-- Aggregated order metrics must reconcile with raw joined order_items.
-- Expected result: order_diff = 0, item_diff = 0, sales_diff = 0.

WITH eligible_orders AS (
  SELECT
    order_id,
    user_id,
    created_at
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status = 'Complete'
),

order_metrics AS (
  SELECT
    eo.order_id,
    COUNT(*) AS item_count,
    SUM(oi.sale_price) AS order_value
  FROM eligible_orders eo
  INNER JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON eo.order_id = oi.order_id
  GROUP BY eo.order_id
),

aggregated AS (
  SELECT
    COUNT(DISTINCT order_id) AS order_count,
    SUM(item_count) AS item_count,
    SUM(order_value) AS gross_sales
  FROM order_metrics
),

raw AS (
  SELECT
    COUNT(DISTINCT eo.order_id) AS order_count,
    COUNT(*) AS item_count,
    SUM(oi.sale_price) AS gross_sales
  FROM eligible_orders eo
  INNER JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON eo.order_id = oi.order_id
)

SELECT
  aggregated.order_count AS agg_orders,
  raw.order_count AS raw_orders,
  aggregated.item_count AS agg_items,
  raw.item_count AS raw_items,
  aggregated.gross_sales AS agg_sales,
  raw.gross_sales AS raw_sales,
  aggregated.order_count - raw.order_count AS order_diff,
  aggregated.item_count - raw.item_count AS item_diff,
  aggregated.gross_sales - raw.gross_sales AS sales_diff
FROM aggregated
CROSS JOIN raw;
