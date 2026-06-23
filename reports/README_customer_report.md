# Customer Report — `gold.customer_report`

## Overview

This SQL view consolidates all key customer-level metrics and behaviors into a single reusable layer. It is designed to support CRM analysis, customer retention strategy, and segmentation-based decision making.

---

## Query Architecture

The report is built using **two layered CTEs** before the final `SELECT`:

```
gold.fact_sales  ──┐
                   ├──► CTE_customer_report_base_query  ──► CTE_customers_aggregations  ──► Final SELECT (VIEW)
gold.dim_customers ┘
```

### CTE 1 — `CTE_customer_report_base_query`
Joins `fact_sales` with `dim_customers` to pull transaction-level detail per customer, including:
- Order number, order date, sales amount, quantity, product key
- Customer key, number, full name (concatenated from first + last)
- Age (calculated dynamically using `DATEDIFF(year, birthdate, GETDATE())`)

Filters out records where `order_date` or age is `NULL` to ensure clean aggregation.

### CTE 2 — `CTE_customers_aggregations`
Groups by customer to compute lifetime metrics:

| Metric | Logic |
|---|---|
| `total_orders` | `COUNT(DISTINCT order_number)` |
| `total_sales` | `SUM(sales_amount)` |
| `total_quantity` | `SUM(quantity)` |
| `total_products` | `COUNT(DISTINCT product_key)` |
| `last_order_date` | `MAX(order_date)` |
| `lifespan` | `DATEDIFF(month, MIN(order_date), MAX(order_date))` |

### Final SELECT — Segmentation & KPIs

**Age Group Segmentation** (`CASE WHEN`):

| Bucket | Condition |
|---|---|
| Under 20 | age < 20 |
| 20–29 | age BETWEEN 20 AND 29 |
| 30–39 | age BETWEEN 30 AND 39 |
| 40–49 | age BETWEEN 40 AND 49 |
| Above 50 | age >= 50 |

**Customer Segment** (`CASE WHEN` on lifespan + total_sales):

| Segment | Condition |
|---|---|
| VIP | lifespan ≥ 12 months AND total_sales > 5,000 |
| Regular | lifespan ≥ 12 months AND total_sales ≤ 5,000 |
| New | lifespan < 12 months |

**Derived KPIs**:

| KPI | Formula |
|---|---|
| `avg_order_value` | `total_sales / total_orders` (0 if no sales) |
| `recency` | `DATEDIFF(month, last_order_date, GETDATE())` |
| `avg_monthly_spend` | `total_sales / lifespan` (uses total_sales if lifespan = 0) |

---

## Output Columns

| Column | Type | Description |
|---|---|---|
| `customer_key` | INT | Surrogate key |
| `customer_number` | VARCHAR | Business identifier |
| `customer_name` | VARCHAR | Full name |
| `age` | INT | Current age in years |
| `age_group` | VARCHAR | Age bucket label |
| `customer_segments` | VARCHAR | VIP / Regular / New |
| `total_orders` | INT | Distinct order count |
| `total_sales` | DECIMAL | Lifetime revenue |
| `avg_order_value` | DECIMAL | Revenue per order |
| `total_quantity` | INT | Total items purchased |
| `total_products` | INT | Distinct products bought |
| `last_order_date` | DATE | Date of most recent order |
| `recency` | INT | Months since last order |
| `lifespan` | INT | Months between first and last order |
| `avg_monthly_spend` | DECIMAL | Average spend per active month |

---

## Usage

```sql
-- Query the view
SELECT * FROM gold.customer_report;

-- Filter for VIP customers only
SELECT customer_name, total_sales, recency
FROM gold.customer_report
WHERE customer_segments = 'VIP'
ORDER BY total_sales DESC;

-- Analyse spend by age group
SELECT age_group, COUNT(*) AS total_customers, AVG(avg_monthly_spend) AS avg_spend
FROM gold.customer_report
GROUP BY age_group
ORDER BY avg_spend DESC;
```

---

## Business Use Cases

- Identify high-value (VIP) customers for loyalty or retention campaigns
- Flag churning customers using `recency` (e.g., no purchase in 6+ months)
- Tailor marketing by `age_group` or `customer_segments`
- Track `avg_monthly_spend` trends for cohort analysis
