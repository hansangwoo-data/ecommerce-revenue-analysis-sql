-- validation_03_price_band_coverage.sql
-- Every eligible item must map to exactly one price band.
-- Expected result: null_price_items = 0 and unclassified_items = 0.

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
      WHEN sale_price < 30 THEN 'Low'
      WHEN sale_price < 80 THEN 'Mid'
      WHEN sale_price >= 80 THEN 'High'
    END AS price_band
  FROM eligible_items
)

SELECT
  COUNT(*) AS total_items,
  COUNTIF(sale_price IS NULL) AS null_price_items,
  COUNTIF(price_band IS NULL) AS unclassified_items
FROM labeled_items;
