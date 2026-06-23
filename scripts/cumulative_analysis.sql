-- calculate the total sales per month
-- and the running total of sales over time
select
orders_month,
total_sales,
sum(total_sales) over(partition by orders_month order by orders_month) running_total
from
(
select
datetrunc(year, order_date) as orders_month,
sum(sales_amount) as total_sales
from gold.fact_sales
where order_date is not null
group by datetrunc(year, order_date)
)t
