--1. How many customers do we have in each city?
select city,count(distinct customerID) Total_customers from dbo.customers
group by city
--2. What are the top three cities where we have our most customers?
select top 3 city,count(distinct customerID) Total_customers from dbo.customers
group by city
order by count(distinct customerID) desc
--3. In terms of sales value, what has been our best selling product of all time?

WITH CTE as (
select productID,sum(unitprice*quantity) as Sales from dbo.orderDetails
group by productID
)
select top 3 a.productID,productName,Sales from CTE as a 
left join dbo.products as b on a.productID=b.productID
order by Sales desc
--4. Northwind’s inventory supply chain team wants a report each day of products that have
--unit prices above the average unit price for all products but below average units in stock
--This helps them better plan restock and purchasing decisions. Product this report for
--them. Sort the results by the product name alphabetically

select productName,unitprice,unitsinstock
from dbo.products
where unitprice>(select avg(unitPrice) from dbo.products) AND
unitPrice<(select avg(unitsInStock) from dbo.products)
order by productName asc;

--5. What is the average number of orders processed by a Northwind employee?

select round((select count(distinct orderid) as Total_orderid
from dbo.orders)/
(select count(distinct employeeid) as Total_employeeid
from dbo.orders),4) as avg_orders_per_empolyee

--6-Which product categories have the above average line item total discounted value (this is
--defined as discount * unitprice * quantity at the order details level). Sort the results by
--the product category alphabetically.
with CTE as (
select productid,unitprice*quantity*discount as average_line_item
from dbo.orderDetails)
, CTA as (select productid,categoryid
from dbo.products)
,CTB as (select categoryname,CategoryID
from dbo.categories)
select CategoryName,avg(average_line_item) as average_line_item
from CTE as a 
left join CTA as b on a.productID=b.productID
left join CTB as c on b.categoryid=c.categoryid
group by CategoryName
order by CategoryName
--7-Using a GROUP BY statement, produce a report containing the companyname, contactname, and
--num_orders (number of orders) that each company has made. Show the top five companies
--that have had the most orders. Do not use a subquery in this question.
select top 5 a.customerid,companyname,contactname,count(distinct orderid) as num_orders
from dbo.customers as a
left join dbo.orders as b on a.customerID=b.customerID
group by a.customerid,companyname,contactname
order by num_orders desc
--7--. Northwind wants to ensure that all customers purchase at least one order. Produce a
--report showing a list of countries where customers have not ordered, and how many customers there are in these countries.

select a.customerID,country,count(a.customerID) as number_of_no_order_customer
from dbo.customers as a 
left join dbo.orders as b on a.customerID=b.customerID
where orderid is null
group by a.customerID,country

--8--. Produce a report showing all customers IDs and number of orders placed for customers
--who have more than the average number of orders per customer. Show the top ordering
--customers first and limit your output to the top 5 countries.

select top 5 customerid,count(distinct orderid) as num_orders
from dbo.orders
group by customerid
having count(distinct orderid)> (select count(distinct orderid)from dbo.orders)/
(select count(distinct customerid) from dbo.orders)
order by  count(distinct orderid) desc
--8.Northwind always wants to ensure that the best selling products are in stock. There is a
--Tableau dashboard that is connected to the enterprise data warehouse which displays the
--average unitsinstock for top products. Write the backend SQL query that will compute
--the average unitsinstock for the top 5 best selling products. We define best selling as the
--total order value of a product as computed using unitprice * quantity.

with cte_demo as(
select top 5 a.productid,sum(a.unitprice*a.quantity) as total_order_value,unitsInStock
from dbo.orderDetails as a 
left join dbo.products as b on a.productID=b.productid
group by a.productID,unitsInStock
order by sum(a.unitprice*a.quantity) desc)
select avg(unitsinstock) as unitsInStock_for_best_selling_products
from cte_demo
