# SQL-EDA-Project-Customer-Product-Analytics
A structured SQL-based Exploratory Data Analysis (EDA) project built on a retail sales database. The project progresses from foundational data exploration through to advanced analytics and production-ready business reports.
📁 Project Structure
```
sql-eda-project/
│
├── eda_foundation/               # Phase 1 — Data exploration fundamentals
│   ├── data_exploration.sql      # Schema discovery, table and column inspection
│   ├── dimension_exploration.sql # Unique countries, categories, subcategories
│   ├── date_dimensions.sql       # Sales date range, customer age range
│   ├── measures_exploration.sql  # Core KPIs: total sales, orders, customers
│   ├── magnitude_measures.sql    # Grouped metrics by country, gender, category
│   └── ranking_measures.sql      # Top/bottom products by revenue (TOP N + ROW_NUMBER)
│
├── advanced_eda/                 # Phase 2 — Advanced analytical techniques
│   ├── change_over_time.sql      # Monthly & yearly sales trends
│   ├── cumulative_analysis.sql   # Running total of sales over time
│   ├── performance_analysis.sql  # YoY product performance + vs. average benchmark
│   ├── part_to_whole.sql         # Category contribution (% of total sales)
│   ├── data_segmentation_1.sql   # Product segmentation by cost range
│   └── data_segmentation_2.sql   # Customer segmentation: VIP / Regular / New
│
├── reports/                      # Phase 3 — Final business report views
│   ├── customer_report.sql       # gold.customer_report VIEW
│   └── product_report.sql        # gold.product_report VIEW
│
└── README.md
```
---
🗄️ Database Schema
The project uses a Gold layer dimensional model with three core tables:
Table	Description
`gold.fact_sales`	Transactional sales data (orders, amounts, quantities, dates)
`gold.dim_customers`	Customer dimension (demographics, location, birth date)
`gold.dim_products`	Product dimension (name, category, subcategory, cost)
---
📊 Phase 1 — EDA Foundation
Establishing familiarity with the data before any analysis.
File	What it does
`data_exploration.sql`	Queries `INFORMATION_SCHEMA` to list all tables and inspect column metadata
`dimension_exploration.sql`	Lists all distinct countries and the full product category hierarchy
`date_dimensions.sql`	Finds first/last order dates, sales range in years/months, and youngest/oldest customer ages
`measures_exploration.sql`	Computes all core KPIs in a single unified `UNION ALL` report
`magnitude_measures.sql`	Breaks down customers by country and gender; products and revenue by category
`ranking_measures.sql`	Identifies top 5 and bottom 5 products by revenue using both `TOP N` and `ROW_NUMBER()`
---
🔬 Phase 2 — Advanced EDA
Deeper analysis using window functions, CTEs, and time-series techniques.
File	Technique Used	Business Question Answered
`change_over_time.sql`	`YEAR()`, `MONTH()`, `DATETRUNC()`	How have monthly and yearly sales trended?
`cumulative_analysis.sql`	`SUM() OVER (ORDER BY …)`	What is the running total of revenue over time?
`performance_analysis.sql`	`LAG()`, `AVG() OVER (PARTITION BY …)`	Is each product's yearly revenue growing or declining vs. prior year and its own average?
`part_to_whole.sql`	`SUM() OVER()`, `CONCAT`, `ROUND`	What percentage of total sales does each category contribute?
`data_segmentation_1.sql`	`CASE WHEN`, CTE	How many products fall into each cost range bucket?
`data_segmentation_2.sql`	CTE + `DATEDIFF`, `CASE WHEN`	How many customers are VIP, Regular, or New based on spend and tenure?
---
📋 Phase 3 — Business Reports
Two production-grade SQL views built on top of the EDA findings.
🧍 Customer Report (`gold.customer_report`)
> See [`reports/customer_report.sql`](reports/customer_report.sql) | [Detailed README](reports/README_customer_report.md)
A consolidated customer-level view covering segmentation, lifetime value indicators, and engagement KPIs.
📦 Product Report (`gold.product_report`)
> See [`reports/product_report.sql`](reports/product_report.sql) | [Detailed README](reports/README_product_report.md)
A consolidated product-level view covering performance tiers, revenue metrics, and recency tracking.
---
🛠️ SQL Techniques Used
CTEs (`WITH` clause) for modular, readable query structure
Window Functions: `ROW_NUMBER()`, `LAG()`, `AVG() OVER()`, `SUM() OVER()`
Date Functions: `DATEDIFF()`, `DATETRUNC()`, `YEAR()`, `MONTH()`, `GETDATE()`
Conditional Logic: `CASE WHEN` for segmentation and classification
Aggregations: `SUM`, `COUNT DISTINCT`, `AVG`, `MIN`, `MAX`
Joins: `LEFT JOIN` across fact and dimension tables
Schema Inspection: `INFORMATION_SCHEMA.TABLES`, `INFORMATION_SCHEMA.COLUMNS`
SQL Views: `CREATE VIEW` for reusable report layers
---
💾 Environment
Database: Microsoft SQL Server (T-SQL syntax)
Schema: Gold layer of a medallion architecture (Bronze → Silver → Gold)
