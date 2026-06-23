/*
==================================================================================================
Product Report
==================================================================================================
Purpose: 
	-This report consolidates key product metrics and behaviours

Highlights:
	1. Gather essential fields such as product name, category, sub category and cost.
	2. Segments products by revenue to identify High-Performers, Mid-Range and Low-Performers.
	3. Aggregates product level metrics:
		-total order
		-total sales
		-total quantity sold
		-total customers (unique)
		-lifespan (in months)
	4. calculate valuable KPI:
		-recency(months since last sale)
		-average order revenue
		-average monthly revenue
===================================================================================================
*/
create view gold.product_report as
with CTE_base_query as
(
/* ===================================================================
1. Base Query: Retrieves core columns from fact_sales and dim_products
====================================================================*/
select
f.order_number,
f.product_key,
f.customer_key,
f.order_date,
f.sales_amount,
f.quantity,
p.product_name,
p.category,
p.subcategory,
p.cost
from gold.fact_sales f
left join gold.dim_products p 
on f.product_key = p.product_key
where order_date is not null  -- only consider valid sales dates
)
, CTE_products_aggregations as
(
/*=====================================================================
Product Aggregations: Summarize ket metrics at the product level
=====================================================================*/
select
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	max(order_date) as last_date_order,
	count(distinct customer_key) as total_customer,
	count(distinct order_number) as total_orders,
	datediff(month, min(order_date), max(order_date)) as lifespan,
	sum(sales_amount) as total_sales,
	sum(quantity) as total_quantity,
	round(avg(cast(sales_amount as float) / nullif(quantity, 0)), 1) as avg_selling_price
from CTE_base_query
group by 
	product_key,
	product_name,
	category,
	subcategory,
	cost
)
/*=============================================================
3. Final Query: Combines all product results into one output
=============================================================*/
select
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_date_order,
	-- finding recency in months
	datediff(month, last_date_order, getdate()) as recency,
	total_customer,
	total_orders,
	lifespan,
	total_sales,
case when total_sales > 50000 then 'High Performer'
	 when total_sales >= 10000 then 'Mid Performer'
	 else 'Low Performer'
end as product_segment,
	total_quantity,
	avg_selling_price,
	-- Average order revenue (AOR)
	case when total_orders = 0 then 0
	else total_sales / total_orders 
end as avg_order_revenue,
	-- Average monthly revenue
case when lifespan = 0 then total_sales	
	else total_sales / lifespan 
end as avg_monthly_revenue
from CTE_products_aggregations