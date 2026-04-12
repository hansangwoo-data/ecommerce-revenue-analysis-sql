-- 02_category_analysis.sql
-- <Objective>
-- Analyze revenue and order distribution across product categories.

-- <Data Source>
-- order_items + products

SELECT
  p.category,

  COUNT(*) AS purchase_count,                
  COUNT(DISTINCT o.order_id) AS order_count, 
  SUM(oi.sale_price) AS revenue,             
  AVG(oi.sale_price) AS avg_price       

FROM `bigquery-public-data.thelook_ecommerce.orders` o

LEFT JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
  ON o.order_id = oi.order_id

LEFT JOIN `bigquery-public-data.thelook_ecommerce.products` p
  ON oi.product_id = p.id

GROUP BY p.category

ORDER BY revenue DESC