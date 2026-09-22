-- validation_02_price_sales_reconciliation.sql
-- Price-band gross sales must reconcile with raw completed item sales.
-- Expected result: sales_diff = 0.

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
    SUM(sale_price) AS gross_sales
  FROM labeled_items
  GROUP BY price_band
)

SELECT
  (SELECT SUM(sale_price) FROM eligible_items) AS raw_sales,
  (SELECT SUM(gross_sales) FROM price_summary) AS price_band_sales,
  (SELECT SUM(sale_price) FROM eligible_items)
    - (SELECT SUM(gross_sales) FROM price_summary) AS sales_diff;
