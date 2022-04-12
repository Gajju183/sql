--Questions 1  - Diffrence between union and union all
union = unique
union all = all(includes duplicate)


-- Cumulative Sum


-- DENSE_RANK() TOP EACH GROUP (without gaps 1 ,22,3)

select * FROM (select market_code, product_code,SUM(sales_amount) revenue, 
   dense_rank() over ( partition by market_code order by SUM(sales_amount) desc  ) 
   as "rank" from transactions group by 1,2) t Where t.rank <= 5 ;

-- RANK (without gaps 1 ,2,2,4)

select * FROM (select market_code, product_code,SUM(sales_amount) revenue, 
   Rank() over ( partition by market_code order by SUM(sales_amount) desc  ) 
   as "rank" from transactions group by 1,2) t Where t.rank <= 5 ;


-- Percent rank (for median or percentile)

select * FROM (select market_code, product_code,SUM(sales_amount) revenue, 
   percent_rank() over ( partition by market_code order by SUM(sales_amount) desc  ) 
   as "rank" from transactions group by 1,2) t Where t.rank <= .5 ;


--LAG (Same previous duration data)

SELECT market_code, month(order_date), SUM(sales_amount) revenue,
LAG (SUM(sales_amount) , 1, 0) 
OVER (PARTITION BY market_code ORDER BY month(order_date)) AS PrevDayRevenue  
FROM transactions
GROUP BY 1,2 ORDER BY 1,2;

--LEAD (Same next duration data)

SELECT market_code, month(order_date), SUM(sales_amount) revenue,
LEAD (SUM(sales_amount) , 1, 0) 
OVER (PARTITION BY market_code ORDER BY month(order_date)) AS PrevDayRevenue  
FROM transactions
GROUP BY 1,2 ORDER BY 1,2;

-- How to get Nth record of table
SELECT * FROM (SELECT productName, SUM(quantityInStock) QTY, dense_rank() over(order by SUM(quantityInStock) DESC) as 'rank' 
FROM classicmodels.products group by 1) t where t.rank = 5

-- By Row NUmber
SELECT * FROM
	(SELECT productName, SUM(quantityInStock) QTY, 
	ROW_NUMBER() over(order by SUM(quantityInStock) DESC) as 'rank' 
FROM classicmodels.products group by 1) t where t.rank = 5

-- Difference between DELETE, DROP and TRUNCATE

DELETE - delate any record of table
DROP - Delete / drop full table
TRUNCATE - to delete all table records

--difference between union and join in sql

JOIN - It combines data into new columns., Number of columns selected from each table may not be same.
UNION - It combines data into new rows, Number of columns selected from each table should be same.

-- create new empty table from existing table
CREATE TABLE products_copy 
  AS (SELECT * 
      FROM products WHERE 1=2); 

-- Creating a view

CREATE VIEW products_view 
  AS SELECT * FROM products WHERE productLine='Motorcycles'; 

--What is the difference between Clustered and Non-Clustered Indexes in SQL Server?

1- There can be only one clustered index per table. However, you can create multiple non-clustered indexes on a single table.
2 - Clustered indexes only sort tables. Therefore, they do not consume extra storage. Non-clustered indexes are stored in a separate place from the actual table claiming more storage space.
3- Clustered indexes are faster than non-clustered indexes since they don’t involve any extra lookup step.



--Group data on conditions and remaining in other

SELECT CASE
    WHEN productLine = 'Vintage Cars' AND quantityInStock < 1000 THEN 'Vintage Cars < 1000'    
    WHEN productLine = 'Vintage Cars' AND quantityInStock > 2000 AND quantityInStock < 3000 THEN 'Vintage Cars 1000 >< 3000' 
    WHEN productLine = 'Classic Cars' AND quantityInStock > 3000 THEN 'Vintage Cars > 3000'     
    ELSE 'other' END AS 'new_product_line',
    quantityInStock, SUM(MSRP) Revenue
FROM classicmodels.products GROUP BY 1,2 ORDER BY 1 DESC;