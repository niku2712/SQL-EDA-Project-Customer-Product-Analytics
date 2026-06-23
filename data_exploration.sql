-- explore all objects in the database

select * from information_schema.tables

-- explore all the columns in the database

select * from INFORMATION_SCHEMA.columns
where table_name = 'dim_customers'