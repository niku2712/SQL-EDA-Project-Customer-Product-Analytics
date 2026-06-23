/* 
=============================================================================================
Customer Report
=============================================================================================
Purpose:
	-This report consolidates key customer metrics and behaviors

Highlights: 
1. Gathers essential fields such as name, age and transaction details.
2. Segments customers into category (VIP, Regular, New) and age group
3. Aggregate customer level metrics:
	-Total orders
	-Total sales
	-Total quantity purchased
	-Total products
	-lifespan (in months)
4. calculate variable KPIs
	-recency(months since last order)
	-average order value
	-average monthly spend
============================================================================================
*/
/*==============================
  Create a view 
===============================*/

create view gold.customer_report as
/* -------------------------------------------------
1. Base Query: Retrieve core columns from the tables
----------------------------------------------------*/
with CTE_customer_report_base_query as
(
select
f.order_number,
f.order_date,
f.sales_amount,
f.quantity,
f.product_key,
c.customer_key,
c.customer_number,
concat(c.first_name, ' ' ,c.last_name) as customer_name,
datediff(year, c.birthdate, getdate()) age
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
where order_date is not null and datediff(year, c.birthdate, getdate()) is not null
)
, CTE_customers_aggragations as
(
/* ----------------------------------------------------------------------
2. Customer Aggreagations: Summarize the key metrics at the customer leve
-----------------------------------------------------------------------*/

select
	customer_key,
	customer_number,
	customer_name,
	age,
	count(distinct order_number) as total_orders,
	sum(sales_amount) as total_sales,
	sum(quantity) as total_quantity,
	count(distinct product_key) as total_products,
	max(order_date) as last_order_date,
	datediff(month, min(order_date), max(order_date)) as lifespan
from CTE_customer_report_base_query
group by 
	customer_key,
	customer_number,
	customer_name,
	age
)
select
	customer_key,
	customer_number,
	customer_name,
	age,
case when age < 20 then 'Under 20'
	 when age between 20 and 29 then '20-29'
	 when age between 30 and 39 then '30-39'
	 when age between 40 and 49 then '40-49'
	 else 'Above 50'
end as age_group,
case 
	 when lifespan >=12 and total_sales > 5000 then 'VIP'
	 when lifespan >=12 and total_sales <= 5000 then 'regular'
	 else 'new'
end as customer_segments,
	total_orders,
	total_sales,
-- compute avg order value (AVO)
case when total_sales = 0 then 0
	 else total_sales / total_orders
end as avg_order_value,
	total_quantity,
	total_products,
	last_order_date,
	-- compute the recency by customers
	datediff(month, last_order_date, getdate()) as recency,
	lifespan,
	-- compute avg monthly spend
case when lifespan = 0 then total_sales
	 else total_sales / lifespan
end as avg_monthly_spend
from CTE_customers_aggragations






