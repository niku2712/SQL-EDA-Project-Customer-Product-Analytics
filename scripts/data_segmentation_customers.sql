/* group customers into three segments based on their spending behavior
	- VIP: customers with at least 12 months of history and spending more than 5000
	- regular: customers with at least 12 months of history and spending 5000 or less
	- new: customers with a lifespan less than 12 months 
and find the total number of customers by each group */
with cte_customer_spending as 
(
select
c.customer_key,
sum(f.sales_amount) as total_spending,
min(f.order_date) as first_order,
max(f.order_date) as last_order,
datediff(month, min(f.order_date), max(f.order_date)) as lifespan
from gold.dim_customers c
left join gold.fact_sales f
on c.customer_key = f.customer_key
group by c.customer_key)

select
count(customer_key) as total_customers,
customer_segments
from (
select
customer_key,
total_spending,
lifespan,
case when lifespan >=12 and total_spending > 5000 then 'VIP'
	 when lifespan >=12 and total_spending <= 5000 then 'regular'
	 else 'new'
end as customer_segments
from cte_customer_spending)t
group by customer_segments
order by total_customers desc