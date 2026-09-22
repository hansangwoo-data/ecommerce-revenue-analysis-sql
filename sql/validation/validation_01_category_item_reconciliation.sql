-- validation_01_category_item_reconciliation.sql
-- Sum of category item_count must equal the number of completed
-- order-item rows that successfully map to a product category.
-- Expected result: item_diff = 0.

WITH eligible_items AS (
  SELECT
    o.order_id,
    oi.product_id,
    oi.sale_price
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  INNER JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.status = 'Complete'
),

mapped_items AS (
  SELECT
    ei.order_id,
    ei.product_id,
    ei.sale_price,
    p.category
  FROM eligible_items ei
  INNER JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON ei.product_id = p.id
),

category_summary AS (
  SELECT
    category,
    COUNT(*) AS item_count
  FROM mapped_items
  GROUP BY category
)

SELECT
  (SELECT COUNT(*) FROM mapped_items) AS raw_mapped_items,
  (SELECT SUM(item_count) FROM category_summary) AS category_items,
  (SELECT COUNT(*) FROM mapped_items)
    - (SELECT SUM(item_count) FROM category_summary) AS item_diff;
