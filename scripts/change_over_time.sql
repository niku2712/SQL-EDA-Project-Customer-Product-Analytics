-- analyse sales performance over time

select
year(order_date) as order_year,
month(order_date) as order_month,
count(customer_key) as total_customer,
sum(sales_amount) as total_sales
from gold.fact_sales
where order_date is not null
group by year(order_date), month(order_date)
order by year(order_date), month(order_date)

select
datetrunc(year, order_date) as order_year,
count(customer_key) as total_customer,
sum(sales_amount) as total_sales
from gold.fact_sales
where order_date is not null
group by datetrunc(year, order_date)
order by total_sales 