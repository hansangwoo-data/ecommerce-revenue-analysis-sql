-- validation_01_price_item_reconciliation.sql
-- Price-band item totals must equal the eligible completed item population.
-- Expected result: item_diff = 0.

WITH eligible_items AS (
  SELECT
    o.order_id,
    oi.sale_price
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  INNER JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.status = 'Complete'
),

labeled_items AS (
  SELECT
    order_id,
    sale_price,
    CASE
      WHEN sale_price IS NULL THEN NULL
      WHEN sale_price < 30 THEN 'Low'
      WHEN sale_price < 80 THEN 'Mid'
      WHEN sale_price >= 80 THEN 'High'
    END AS price_band
  FROM eligible_items
),

price_summary AS (
  SELECT
    price_band,
    COUNT(*) AS item_count
  FROM labeled_items
  GROUP BY price_band
)

SELECT
  (SELECT COUNT(*) FROM eligible_items) AS raw_items,
  (SELECT SUM(item_count) FROM price_summary) AS price_band_items,
  (SELECT COUNT(*) FROM eligible_items)
    - (SELECT SUM(item_count) FROM price_summary) AS item_diff;
