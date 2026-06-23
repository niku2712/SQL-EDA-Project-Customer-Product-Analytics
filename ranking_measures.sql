-- find the top 5 products which generates the highest revenue

select top 5
p.product_name,
sum(f.sales_amount) as total_revenue
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
group by p.product_name
order by total_revenue desc

select *
from (
	select 
	p.product_name,
	sum(f.sales_amount) as total_revenue,
	row_number() over(order by sum(f.sales_amount) desc) as rank_product
	from gold.fact_sales f
	left join gold.dim_products p
	on p.product_key = f.product_key
	group by p.product_name)t
where rank_product <=5

-- what are the worst 5 performing products in terms of sales

select top 5
p.product_name,
sum(f.sales_amount) as total_revenue
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
group by p.product_name
order by total_revenue 