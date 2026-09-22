-- Source integrity and category reconciliation (one summary row).
-- Eligibility: orders.status = 'Complete'; no separate item-status filter.
-- ID checks cover entire source tables. duplicate_*_rows counts excess
-- non-NULL occurrences, separately from NULL IDs. Anomaly counts should be 0.
-- Category totals mirror 02_category_analysis.sql, including its NULL group.
-- Diffs are category totals minus PRE-product-join totals; expect item_diff = 0
-- and ABS(sales_diff) < 0.01 USD (FLOAT64 aggregation tolerance).
-- Coverage counts below are joined rows; duplicate product IDs can inflate them.
-- Check every anomaly separately: losses and duplication can offset in totals.
-- NULL sales are counted separately; SUM ignores them, COALESCE handles no rows.

WITH orders AS (
  SELECT * FROM `bigquery-public-data.thelook_ecommerce.orders`
),
items AS (
  SELECT * FROM `bigquery-public-data.thelook_ecommerce.order_items`
),
products AS (
  SELECT * FROM `bigquery-public-data.thelook_ecommerce.products`
),
completed_orders AS (
  SELECT * FROM orders WHERE status = 'Complete'
),
eligible_items AS (
  SELECT oi.product_id, oi.sale_price
  FROM completed_orders o
  INNER JOIN items oi ON o.order_id = oi.order_id
),
category_coverage AS (
  SELECT ei.sale_price, p.id AS matched_product_id, p.category
  FROM eligible_items ei
  LEFT JOIN products p ON ei.product_id = p.id
),
category_summary AS (
  SELECT category, COUNT(*) AS item_count, SUM(sale_price) AS gross_sales
  FROM category_coverage
  WHERE matched_product_id IS NOT NULL
  GROUP BY category
),
source_ids AS (
  SELECT
    (SELECT COUNTIF(order_id IS NULL) FROM orders) AS null_order_ids,
    (SELECT COUNT(order_id) - COUNT(DISTINCT order_id) FROM orders) AS duplicate_order_id_rows,
    (SELECT COUNTIF(id IS NULL) FROM items) AS null_item_ids,
    (SELECT COUNT(id) - COUNT(DISTINCT id) FROM items) AS duplicate_item_id_rows,
    (SELECT COUNTIF(id IS NULL) FROM products) AS null_product_ids,
    (SELECT COUNT(id) - COUNT(DISTINCT id) FROM products) AS duplicate_product_id_rows
),
order_integrity AS (
  SELECT
    COUNT(*) AS completed_order_rows,
    COUNTIF(user_id IS NULL) AS completed_null_user_ids,
    COUNTIF(created_at IS NULL) AS completed_null_created_at,
    (SELECT COUNT(*) FROM completed_orders o
     WHERE NOT EXISTS (SELECT 1 FROM items oi WHERE oi.order_id = o.order_id)
    ) AS completed_orders_without_items
  FROM completed_orders
),
item_integrity AS (
  SELECT
    COUNT(*) AS pre_product_join_items,
    COALESCE(SUM(sale_price), 0) AS pre_product_join_sales,
    COUNTIF(sale_price IS NULL) AS null_sale_price_items,
    COUNTIF(sale_price < 0) AS negative_sale_price_items
  FROM eligible_items
),
coverage AS (
  SELECT
    COUNTIF(matched_product_id IS NULL) AS unmatched_product_items,
    COALESCE(SUM(CASE WHEN matched_product_id IS NULL THEN sale_price END), 0) AS unmatched_product_sales,
    COUNTIF(matched_product_id IS NOT NULL AND category IS NULL) AS matched_null_category_items,
    COALESCE(SUM(CASE WHEN matched_product_id IS NOT NULL AND category IS NULL
      THEN sale_price END), 0) AS matched_null_category_sales
  FROM category_coverage
),
category_totals AS (
  SELECT COALESCE(SUM(item_count), 0) AS category_items,
    COALESCE(SUM(gross_sales), 0) AS category_sales
  FROM category_summary
)
SELECT source_ids.*, order_integrity.*, item_integrity.*, coverage.*, category_totals.*,
  category_items - pre_product_join_items AS item_diff,
  category_sales - pre_product_join_sales AS sales_diff
FROM source_ids
CROSS JOIN order_integrity
CROSS JOIN item_integrity
CROSS JOIN coverage
CROSS JOIN category_totals;
