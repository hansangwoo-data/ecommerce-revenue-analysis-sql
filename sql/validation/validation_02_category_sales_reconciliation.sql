-- validation_02_category_sales_reconciliation.sql
-- Sum of category gross_sales must equal sales from the same
-- mapped completed order-item population.
-- Expected result: sales_diff = 0.

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
    ei.sale_price,
    p.category
  FROM eligible_items ei
  INNER JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON ei.product_id = p.id
),

category_summary AS (
  SELECT
    category,
    SUM(sale_price) AS gross_sales
  FROM mapped_items
  GROUP BY category
)

SELECT
  (SELECT SUM(sale_price) FROM mapped_items) AS raw_mapped_sales,
  (SELECT SUM(gross_sales) FROM category_summary) AS category_sales,
  (SELECT SUM(sale_price) FROM mapped_items)
    - (SELECT SUM(gross_sales) FROM category_summary) AS sales_diff;
