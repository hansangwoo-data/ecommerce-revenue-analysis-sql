-- 03_price_analysis.sql
-- <Objective>
-- Compare completed-order item volume and gross sales across
-- analysis-defined price bands.
--
-- <Scope>
-- Only orders with status = 'Complete' are included.
--
-- <Price Band Definition>
-- Low  = sale_price < 30 USD
-- Mid  = 30 <= sale_price < 80 USD
-- High = sale_price >= 80 USD
--
-- These thresholds are analysis-defined descriptive segments,
-- not business-standard pricing tiers.
--
-- <Metric Definitions>
-- item_count          = number of order-item rows in the price band
-- order_count         = distinct completed orders containing the price band
-- gross_sales         = sum of item sale_price
-- avg_item_price      = average item sale_price
-- avg_items_per_order = item_count / order_count
--
-- <Data Source>
-- bigquery-public-data.thelook_ecommerce.orders
-- bigquery-public-data.thelook_ecommerce.order_items

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

price_metrics AS (
  SELECT
    price_band,
    COUNT(*) AS item_count,
    COUNT(DISTINCT order_id) AS order_count,
    SUM(sale_price) AS gross_sales,
    AVG(sale_price) AS avg_item_price
  FROM labeled_items
  GROUP BY price_band
)

SELECT
  price_band,
  item_count,
  order_count,
  gross_sales,
  avg_item_price,
  SAFE_DIVIDE(
    item_count,
    order_count
  ) AS avg_items_per_order
FROM price_metrics
ORDER BY
  CASE price_band
    WHEN 'Low' THEN 1
    WHEN 'Mid' THEN 2
    WHEN 'High' THEN 3
  END;
