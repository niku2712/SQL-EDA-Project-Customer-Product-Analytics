-- analyse the yearly performance of products by comparing their sales
-- to both the average sales performance of the product and the previous year's sales 
with yearly_product_sales as 
(
select
year(f.order_date) as order_years,
p.product_name,
sum(f.sales_amount) current_sales
from gold.fact_sales f
left join gold.dim_products p
on f.product_key = p.product_key
where year(f.order_date) is not null
group by  year(f.order_date), 
p.product_name
)
select
order_years,
product_name,
current_sales,
avg(current_sales) over(partition by product_name) as avg_sales,
current_sales - avg(current_sales) over(partition by product_name) as diff_avgsales,
case when current_sales - avg(current_sales) over(partition by product_name) < 0 then 'below avg'
	when current_sales - avg(current_sales) over(partition by product_name) > 0 then 'above avg'
	 else 'avg'
end as avg_change,
-- year over year analysis
lag(current_sales) over(partition by product_name order by order_years) as previous_years,
current_sales - lag(current_sales) over(partition by product_name order by order_years) as diff_py,
case when current_sales - lag(current_sales) over(partition by product_name order by order_years) < 0 then 'decreasing'
	when current_sales - lag(current_sales) over(partition by product_name order by order_years) > 0 then 'increasing'
	 else 'no change'
end as py_change
from yearly_product_sales

