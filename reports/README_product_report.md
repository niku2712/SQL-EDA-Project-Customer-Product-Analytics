# Product Report — `gold.product_report`

## Overview

This SQL view consolidates all key product-level metrics and performance indicators into a single reusable layer. It supports inventory analysis, product portfolio management, and revenue performance tracking.

---

## Query Architecture

The report uses **two layered CTEs** before the final `SELECT`:

```
gold.fact_sales   ──┐
                    ├──► CTE_base_query  ──► CTE_products_aggregations  ──► Final SELECT (VIEW)
gold.dim_products  ┘
```

### CTE 1 — `CTE_base_query`
Joins `fact_sales` with `dim_products` to pull transaction-level detail per product, including:
- Order number, product key, customer key, order date, sales amount, quantity
- Product name, category, subcategory, cost

Filters out records where `order_date` is `NULL`.

### CTE 2 — `CTE_products_aggregations`
Groups by product to compute lifetime metrics:

| Metric | Logic |
|---|---|
| `last_date_order` | `MAX(order_date)` |
| `total_customer` | `COUNT(DISTINCT customer_key)` |
| `total_orders` | `COUNT(DISTINCT order_number)` |
| `lifespan` | `DATEDIFF(month, MIN(order_date), MAX(order_date))` |
| `total_sales` | `SUM(sales_amount)` |
| `total_quantity` | `SUM(quantity)` |
| `avg_selling_price` | `ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1)` |

Note: `NULLIF(quantity, 0)` prevents division-by-zero errors when computing the average selling price per unit.

### Final SELECT — Segmentation & KPIs

**Product Segment** (`CASE WHEN` on `total_sales`):

| Segment | Condition |
|---|---|
| High Performer | total_sales > 50,000 |
| Mid Performer | total_sales BETWEEN 10,000 AND 50,000 |
| Low Performer | total_sales < 10,000 |

**Derived KPIs**:

| KPI | Formula |
|---|---|
| `recency` | `DATEDIFF(month, last_date_order, GETDATE())` |
| `avg_order_revenue` | `total_sales / total_orders` (0 if no orders) |
| `avg_monthly_revenue` | `total_sales / lifespan` (uses total_sales if lifespan = 0) |

---

## Output Columns

| Column | Type | Description |
|---|---|---|
| `product_key` | INT | Surrogate key |
| `product_name` | VARCHAR | Product display name |
| `category` | VARCHAR | Top-level category |
| `subcategory` | VARCHAR | Sub-level category |
| `cost` | DECIMAL | Unit cost |
| `last_date_order` | DATE | Most recent sale date |
| `recency` | INT | Months since last sale |
| `total_customer` | INT | Unique customers who bought this product |
| `total_orders` | INT | Distinct order count |
| `lifespan` | INT | Months between first and last sale |
| `total_sales` | DECIMAL | Total revenue generated |
| `product_segment` | VARCHAR | High / Mid / Low Performer |
| `total_quantity` | INT | Total units sold |
| `avg_selling_price` | DECIMAL | Average revenue per unit sold |
| `avg_order_revenue` | DECIMAL | Average revenue per order |
| `avg_monthly_revenue` | DECIMAL | Average revenue per active month |

---

## Usage

```sql
-- Query the view
SELECT * FROM gold.product_report;

-- Find all High Performers
SELECT product_name, category, total_sales, avg_monthly_revenue
FROM gold.product_report
WHERE product_segment = 'High Performer'
ORDER BY total_sales DESC;

-- Identify stale products (no sales in 12+ months)
SELECT product_name, last_date_order, recency
FROM gold.product_report
WHERE recency >= 12
ORDER BY recency DESC;

-- Revenue breakdown by category and performance tier
SELECT category, product_segment, COUNT(*) AS product_count, SUM(total_sales) AS category_revenue
FROM gold.product_report
GROUP BY category, product_segment
ORDER BY category, category_revenue DESC;
```

---

## Business Use Cases

- Identify top-performing products for promotional investment
- Spot underperforming or stale products for markdown or discontinuation decisions
- Compare `avg_selling_price` vs `cost` to estimate margin at the product level
- Use `recency` to flag products that may be losing demand
- Analyse `total_customer` to understand reach and cross-sell potential per product
