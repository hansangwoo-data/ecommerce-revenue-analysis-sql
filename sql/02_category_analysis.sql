-- 02_category_analysis.sql
-- <Objective>
-- Compare completed-order sales performance across product categories.
--
-- <Scope>
-- Only orders with status = 'Complete' are included.
--
-- <Metric Definitions>
-- item_count          = number of order-item rows in the category
-- order_count         = distinct completed orders containing the category
-- gross_sales         = sum of item sale_price
-- avg_item_price      = average item sale_price
-- avg_items_per_order = item_count / order_count
--
-- <Data Source>
-- bigquery-public-data.thelook_ecommerce.orders
-- bigquery-public-data.thelook_ecommerce.order_items
-- bigquery-public-data.thelook_ecommerce.products

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

category_metrics AS (
  SELECT
    p.category,
    COUNT(*) AS item_count,
    COUNT(DISTINCT ei.order_id) AS order_count,
    SUM(ei.sale_price) AS gross_sales,
    AVG(ei.sale_price) AS avg_item_price
  FROM eligible_items ei
  INNER JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON ei.product_id = p.id
  GROUP BY p.category
)

SELECT
  category,
  item_count,
  order_count,
  gross_sales,
  avg_item_price,
  SAFE_DIVIDE(
    item_count,
    order_count
  ) AS avg_items_per_order
FROM category_metrics
ORDER BY gross_sales DESC;
