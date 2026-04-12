-- 03_price_analysis.sql
-- <Objective>
-- Analyze how price segmentation influences purchasing behavior and revenue.

-- <Data Source>
-- bigquery-public-data.thelook_ecommerce.orders
-- bigquery-public-data.thelook_ecommerce.order_items

SELECT
  CASE
    WHEN oi.sale_price < 30 THEN 'Low'
    WHEN oi.sale_price < 80 THEN 'Mid'
    ELSE 'High'
  END AS price_band,

  COUNT(*) AS purchase_count,
  COUNT(DISTINCT o.order_id) AS order_count,
  SUM(oi.sale_price) AS revenue,
  AVG(oi.sale_price) AS avg_price

FROM `bigquery-public-data.thelook_ecommerce.orders` o

LEFT JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
  ON o.order_id = oi.order_id

GROUP BY price_band

ORDER BY revenue DESC