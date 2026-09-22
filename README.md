# SQL E-commerce Revenue Analysis

This project analyzes user purchase behavior and revenue patterns using BigQuery's public `thelook_ecommerce` dataset.

SQL queries were written in BigQuery to extract pre-aggregated results, which are then loaded into a Jupyter notebook for visualization and interpretation.

---
## Business Problem

How do purchase stage, product category, and item price relate to gross sales patterns?

This analysis compares completed first vs repeat orders, category-level sales structure, and analysis-defined price bands to describe how repeat purchase activity, item volume, and average item value relate to gross sales.  

---

## Project Structure

```
sql-ecommerce-revenue-analysis/
│
├── README.md
├── data/
│   ├── first_vs_repeat_orders.csv
│   ├── category_analysis.csv
│   └── price_analysis.csv
│
├── notebook/
│   └── sql_ecommerce_revenue_analysis.ipynb
│
├── sql/
│   ├── 01_first_vs_repeat_orders.sql
│   ├── 02_category_analysis.sql
│   ├── 03_price_analysis.sql
│   └── validation/
│       └── validation_*.sql
│
└── images/
    ├── gross_sales_by_order_stage.png
    ├── order_count_by_order_stage.png
    ├── gross_sales_by_category.png
    ├── item_count_by_category.png
    ├── gross_sales_by_price_band.png
    └── item_count_by_price_band.png
```

---

## Reproducing the Results
Aggregate results were exported from BigQuery on 2026-09-22 and are stored in data/.
Run all cells in notebook/sql_ecommerce_revenue_analysis.ipynb to reproduce the tables and six charts. 
Source-level validation queries are available in sql/validation/ and were used to verify order/item coverage, ID integrity, price quality, product mapping, and aggregate reconciliation.
Metric scope
- Only orders with orders.status = 'Complete' are included.
- gross_sales = SUM(order_items.sale_price)
- AOV = gross sales / order count
- First Order = earliest observed completed order by created_at, order_id
- Repeat users are a subset of first-order users, so stage-level user_count values are not additive.

---

## Analysis

### 1. First-order vs Repeat-order Behavior

**Objective**

Compare completed first orders with subsequent completed repeat orders for the same users.

**Key Findings**
- 27,511 users generated at least one completed order.
- 3,316 users generated repeat-order activity, producing 3,655 repeat orders.
- First orders had an average order value of about 86.49 USD, while repeat orders averaged about 88.16 USD.
- Average items per order were similar: about 1.45 for first orders vs 1.47 for repeat orders.
- Average item prices were nearly identical at about 59.67 USD vs 60.05 USD.

**Insight**

Repeat-order activity exists, but repeat orders are not structurally much larger or more expensive than first orders. The main difference is the occurrence of additional purchase activity rather than a major change in basket value.

**Scope Note**

Only orders with `status = 'Complete'` are included. The share of users with repeat orders should not be interpreted as a retention rate because users may have different observation windows.

---

### 2. Category Analysis

**Objective**

Compare gross sales, item volume, order coverage, and average item price across product categories using completed orders only.

**Key Findings**
- Outerwear & Coats generated the highest gross sales (~337K USD) from 2,269 items across 2,219 orders, with an average item price of about 148.72 USD.
- Jeans generated the second-highest gross sales (~308K USD) from 3,203 items across 3,085 orders, with an average item price of about 96.09 USD.
- Intimates recorded the highest item volume (3,323 items) across 3,110 orders but generated about 109K USD in gross sales, with a much lower average item price of about 32.83 USD.

**Insight**

Category revenue reflects the combination of item volume and average item price rather than volume alone. High-volume categories do not necessarily generate the highest gross sales when their average item price is substantially lower.

**Scope Note**

Only orders with `status = 'Complete'` are included. Category-level `order_count` values are not additive across categories because a single order can contain items from multiple categories.

---

### 3. Price Analysis

**Objective**

Compare completed-order item volume and gross sales across analysis-defined price bands.

**Price Band Definition**
- Low: < 30 USD
- Mid: 30 to < 80 USD
- High: >= 80 USD

These thresholds are descriptive segments defined for this analysis, not business-standard pricing tiers. NULL prices remain unclassified rather than falling into High. The user-run validation reported zero NULL prices among items attached to completed orders for the current export; this patch does not change the published results.

**Key Findings**
- Low-priced items: 16,508 items across 14,092 orders, ~317K USD in gross sales, average item price ~19.21 USD.
- Mid-priced items: 19,649 items across 16,393 orders, ~991K USD in gross sales, average item price ~50.43 USD.
- High-priced items: 9,088 items across 8,349 orders, ~1.394M USD in gross sales, average item price ~153.34 USD.

**Insight**

Gross sales distribution differs substantially across price bands because item volume and average item value vary together. High-priced items generated the largest share of gross sales despite lower item volume.

**Scope Note**

Only orders with `status = 'Complete'` are included. Price-band `order_count` values are not additive because a single order can contain items from multiple price bands.

---

## Key Takeaway

Across the three analyses, gross sales are best understood through a combination of repeat purchase activity, item volume, and average item value rather than any single metric alone.

- Repeat orders exist, but their basket value is similar to first orders.
- Category revenue differs because categories combine different levels of item volume and average item price.
- High-priced items contribute the largest share of gross sales despite lower item volume.

---

## Business Implications

The analysis does not identify a single growth lever. Instead, it highlights the importance of separating repeat purchase activity, item volume, and item value when interpreting gross sales performance.

For decision-making, teams should avoid relying on transaction volume alone and should evaluate how repeat purchase behavior and product mix contribute to gross sales.

These findings are descriptive and should be validated with controlled time windows, cohort-based retention analysis, and additional profitability or margin data before being used for strategy decisions.

---

## Tools & Dataset

- **Query**: BigQuery (Google Cloud)
- **Dataset**: `bigquery-public-data.thelook_ecommerce`
- **Visualization**: Python (pandas, matplotlib)
