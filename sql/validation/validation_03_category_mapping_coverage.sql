-- validation_03_category_mapping_coverage.sql
-- Check whether completed order-item rows fail to map to products/categories.
-- Expected result: unmatched_product_items = 0 and null_category_items = 0.

WITH eligible_items AS (
  SELECT
    o.order_id,
    oi.product_id,
    oi.sale_price
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  INNER JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.status = 'Complete'
)

SELECT
  COUNT(*) AS total_completed_items,
  COUNTIF(p.id IS NOT NULL) AS mapped_product_items,
  COUNTIF(p.id IS NULL) AS unmatched_product_items,
  COUNTIF(p.category IS NULL) AS null_category_items
FROM eligible_items ei
LEFT JOIN `bigquery-public-data.thelook_ecommerce.products` p
  ON ei.product_id = p.id;
