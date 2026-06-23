-- explore all countries our customers come from

select distinct country from gold.dim_customers

-- explore all the categories "the major divisions"

select distinct category, subcategory, product_name from gold.dim_products
order by 1,2,3