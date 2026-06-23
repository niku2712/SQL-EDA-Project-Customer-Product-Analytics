-- segment products into cost ranges and
-- count how many products fall into each segment

with CTE_products_segmentation as
(
select
product_key,
product_name,
cost,
case when cost < 100 then 'Below 100'
	 when cost between 100 and 500 then '100 -500'
	 when cost between 500 and 1000 then '500-1000'
	 else 'Above 1000'
end cost_range
from gold.dim_products)

select
count(product_key) as total_products,
cost_range
from CTE_products_segmentation
group by cost_range
order by count(product_key) desc