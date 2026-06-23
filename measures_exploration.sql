-- find the total sales
select sum(sales_amount) as totalsales from gold.fact_sales
-- find how many items are sold
select sum(quantity) as total_item from gold.fact_sales
-- find the average selling price
select avg(price) as avg_sell_price from gold.fact_sales
-- find the total numbers of order
select count(order_number) as totalorders from gold.fact_sales
select count(distinct order_number) as totalorders from gold.fact_sales
-- find the total numbers of products
select count(product_key) as totalproducts from gold.dim_products
-- find the total numbers of customers
select count(customer_number) as totalcustomers from gold.dim_customers
-- find the total numbers of customers that have placed an order
select count(distinct customer_key) as order_placed from gold.fact_sales
-- generate a report that shows all the key metrics

select 'total_sales' as measure_name, sum(sales_amount) as measure_value from gold.fact_sales
union all
select 'total_quantity' as measure_name, sum(quantity) as measure_value from gold.fact_sales
union all
select 'avg_price' as measure_name, avg(price) as measure_value from gold.fact_sales
union all
select 'total Nr_orders' as measure_name, count(distinct order_number) as measure_value from gold.fact_sales
union all
select 'total Nr_products' as measure_name, count(product_key) as measure_value from gold.dim_products
union all
select 'total Nr_customers' as measure_name, count(customer_key) as measure_value from gold.dim_customers