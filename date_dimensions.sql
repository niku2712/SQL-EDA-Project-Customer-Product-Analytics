-- find the date of the first and last order
--how many years of sales are available

select 
min(order_date) as first_orderdate,
max(order_date) as last_orderdate,
datediff(year, min(order_date), max(order_date)) as order_range_years,
datediff(month, min(order_date), max(order_date)) as order_range_months
from gold.fact_sales

--find the youngest and the oldest customer

select
min(birthdate) as youngest_agecustomer,
datediff(year, min(birthdate), getdate()) as oldest_age,
max(birthdate) as oldest_agecustomer,
datediff(year, max(birthdate), getdate()) as youngest_age
from gold.dim_customers
