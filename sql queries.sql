----creating table customer----
create table customers (CustomerID varchar,FirstName varchar, LastName Varchar,
Gender varchar,BirthDate date, City varchar,JoinDate date );

----creating table product----
create table products(ProductID varchar,ProductName varchar,Category varchar,SubCategory varchar,
UnitPrice numeric(10,2),CostPrice numeric(10,2));

----creating table stores----
create table stores(StoreID varchar,StoreName varchar,City varchar,Region varchar);

----creating table transactions----
create table Transactions(TransactionID varchar,Date date,CustomerID varchar,
ProductID varchar,StoreID varchar, Quantity integer,Discount decimal(5,2),PaymentMethod varchar);

select * from Customers;
select * from products;
select * from stores;
select * from transactions;

select count(*) from customers;
select count(*) from products;
select count(*) from stores;
select count(*) from transactions;


--- finding missing values in customers tables ---
SELECT
COUNT(*) AS total_rows,
COUNT(*) - COUNT(customerid) AS missing_customerid,
COUNT(*) - COUNT(firstname) AS missing_firstname,
COUNT(*) - COUNT(lastname) AS missing_lastname,
COUNT(*) - COUNT(gender) AS missing_gender,
COUNT(*) - COUNT(birthdate) AS missing_birthdate,
COUNT(*) - COUNT(city) AS missing_city,
COUNT(*) - COUNT(joindate) AS missing_joindate
FROM customers;


--- finding missing values in products tables ---
SELECT
COUNT(*) AS total_rows,
COUNT(*) - COUNT(productid) AS missing_productid,
COUNT(*) - COUNT(productname) AS missing_productname,
COUNT(*) - COUNT(category) AS missing_category,
COUNT(*) - COUNT(subcategory) AS missing_subcategory,
COUNT(*) - COUNT(unitprice) AS missing_unitprice,
COUNT(*) - COUNT(costprice) AS missing_costprice
FROM products;


--- finding missing values in stores tables ---
SELECT
COUNT(*) AS total_rows,
COUNT(*) - COUNT(storeid) AS missing_storeid,
COUNT(*) - COUNT(storename) AS missing_storename,
COUNT(*) - COUNT(city) AS missing_city,
COUNT(*) - COUNT(region) AS missing_region
FROM stores;


--- finding missing values in transactions tables ---
SELECT
COUNT(*) AS total_rows,
COUNT(*) - COUNT(transactionid) AS missing_transactionid,
COUNT(*) - COUNT(date) AS missing_date,
COUNT(*) - COUNT(customerid) AS missing_customerid,
COUNT(*) - COUNT(productid) AS missing_productid,
COUNT(*) - COUNT(storeid) AS missing_storeid,
COUNT(*) - COUNT(quantity) AS missing_quantity,
COUNT(*) - COUNT(discount) AS missing_discount,
COUNT(*) - COUNT(paymentmethod) AS missing_paymentmethod
FROM transactions;

---finding duplicate records in customers---
SELECT customerid, COUNT(*) AS duplicate_count
FROM customers
GROUP BY customerid
HAVING COUNT(*) > 1;

---finding duplicate records in products---
SELECT productid, COUNT(*) AS duplicate_count
FROM products
GROUP BY productid
HAVING COUNT(*) > 1;

---finding duplicate records in stores---
SELECT storeid, COUNT(*) AS duplicate_count
FROM stores
GROUP BY storeid
HAVING COUNT(*) > 1;

---finding duplicate records in transactions---
SELECT transactionid, COUNT(*) AS duplicate_count
FROM transactions
GROUP BY transactionid
HAVING COUNT(*) > 1;

---checking regrential integrity in customers---
SELECT t.customerid
FROM transactions t
LEFT JOIN customers c
ON t.customerid = c.customerid
WHERE c.customerid IS NULL;

---checking regrential integrity in products---
SELECT t.productid
FROM transactions t
LEFT JOIN products p
ON t.productid = p.productid
WHERE p.productid IS NULL;

---checking regrential integrity in stores---
SELECT t.storeid
FROM transactions t
LEFT JOIN stores s
ON t.storeid = s.storeid
WHERE s.storeid IS NULL;

----checking quantity value consistency---
SELECT *
FROM transactions
WHERE quantity <= 0;

---checking discount range---
SELECT *
FROM transactions
WHERE discount < 0 OR discount > 1;

---checking price range ----
SELECT *
FROM products
WHERE costprice > unitprice;

---combining all tables---
SELECT 
t.transactionid,t.date,
c.customerid,c.gender, c.city AS customer_city,
p.productid,p.productname,
p.category,p.subcategory,
p.unitprice,p.costprice,
s.storeid,s.storename,s.region,
t.quantity,t.discount,t.paymentmethod
from transactions t
join  customers c ON t.customerid = c.customerid
join products p ON t.productid = p.productid
JOIN stores s ON t.storeid = s.storeid;

---calculation of revenue generation from each transaction---
Select 
t.transactionid,
p.productname,
p.category,
t.quantity,
p.unitprice,
t.discount,
(p.unitprice * t.quantity * (1 - t.discount)) AS revenue
from transactions t
join products p ON t.productid = p.productid;

---cost calculation---
SELECT 
t.transactionid,
p.productname,
t.quantity,
p.costprice,
(p.costprice * t.quantity) AS total_cost
FROM transactions t
JOIN products p ON t.productid = p.productid;

---profit calculation---
select
t.transactionid,
p.productname,
p.category,
t.quantity,
p.unitprice,
p.costprice,
t.discount,
(p.unitprice * t.quantity * (1 - t.discount)) AS revenue,
(p.costprice * t.quantity) AS total_cost,
((p.unitprice * t.quantity * (1 - t.discount)) - (p.costprice * t.quantity)) AS profit
from transactions t
join products p ON t.productid = p.productid;

--all table view ---
CREATE VIEW retail_analysis AS
SELECT 
t.transactionid,
t.date,
c.customerid,
c.gender,
p.productname,
p.category,
p.subcategory,
s.region,
t.quantity,
p.unitprice,
p.costprice,
t.discount,
(p.unitprice * t.quantity * (1 - t.discount)) AS revenue,
(p.costprice * t.quantity) AS cost,
((p.unitprice * t.quantity * (1 - t.discount)) - (p.costprice * t.quantity)) AS profit
FROM transactions t
JOIN customers c ON t.customerid = c.customerid
JOIN products p ON t.productid = p.productid
JOIN stores s ON t.storeid = s.storeid;

SELECT * FROM retail_analysis;

--- analysing highest revenue generating category ---
select
category,
SUM(revenue) AS total_revenue
from retail_analysis
GROUP by category
ORDER BY total_revenue DESC;

---analysing most profitable category---
SELECT 
category,
SUM(profit) AS total_profit
FROM retail_analysis
GROUP BY category
ORDER BY total_profit DESC;

---checking discount effectiveness---
select discount,
sum(revenue) AS total_revenue,
sum(profit) AS total_profit
FROM retail_analysis
group BY discount
order BY discount;

----store performance region wise---
select region,
SUM(revenue) AS total_revenue,
SUM(profit) AS total_profit
FROM retail_analysis
GROUP BY region
ORDER BY total_revenue DESC;

---checking customer segments with more revenue----
select gender,
SUM(revenue) AS total_revenue
from retail_analysis GROUP BY gender;

---

