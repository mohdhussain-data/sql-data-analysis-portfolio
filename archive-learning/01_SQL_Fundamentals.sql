/*
FILE: 01_SQL_Fundamentals.sql

DESCRIPTION:
This file contains foundational SQL queries used to explore relational
datasets and retrieve structured information from database tables.
These queries demonstrate the core SQL techniques that form the
foundation of data analysis.

KEY CONCEPTS:
- SELECT statements
- Column selection
- Basic filtering using WHERE
- Sorting results using ORDER BY
- Limiting result sets using LIMIT
*/


--QUESTION:
--Show the first 10 orders with id, account_id, and total_amt_usd.
--LOGIC: Select the required columns and limit the number of rows.

SELECT id,
       account_id,
       total_amt_usd
FROM orders
LIMIT 10;


--QUESTION:
--Show the first 10 accounts with id, name, and website.
--LOGIC: Select the required columns and limit the number of rows.

SELECT id,
       name,
       website
FROM accounts
LIMIT 10;


--QUESTION:
--Show the top 5 orders with the highest total_amt_usd.
--LOGIC: Sort rows by total_amt_usd in descending order and number of rows.

SELECT id,
       account_id,
       total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC
LIMIT 5;


--QUESTION:
--Find all orders where total_amt_usd is greater than 5000. Return id, total_amt_usd.
--LOGIC: Filter rows using a numeric condition on total_amt_usd.

SELECT id,
       total_amt_usd
FROM orders
WHERE total_amt_usd > 5000;


--QUESTION:
--Find all accounts where name is exactly 'Walmart'. Return id, name, website.
--LOGIC: Filter rows using a text condition on name.

SELECT id,
       name,
       website
FROM accounts
WHERE name = 'Walmart';


--QUESTION:
--For each order calculate unit_price = total_amt_usd/total. Return id, total_amt_usd, total, unit_price and limit rows to 10.
--LOGIC: Compute a derived column using arithmetic and alias the result and limit number of rows.

SELECT id,
       total_amt_usd,
       total,
       total_amt_usd/total AS unit_price
FROM orders
LIMIT 10;


--QUESTION:
--Find orders where total_amt_usd is above 5000 and total is above 100. Return id, total_amt_usd, total.
--LOGIC: Filter rows using a numeric condition on the required columns and return the expected columns.

SELECT id,
       total_amt_usd,
       total
FROM orders
WHERE total_amt_usd > 5000 AND total > 100;


--QUESTION:
--Find orders whose total_amt_usd is between 1000 and 5000. Return id, total_amt_usd.
--LOGIC: Filter rows using a text condition on the required columns and return the expected columns.

SELECT id,
       total_amt_usd
FROM orders
WHERE total_amt_usd BETWEEN 1000 AND 5000;


--QUESTION:
--Find all orders where: account_id is IN (1001, 1011, 1021). Return id, account_id, total_amt_usd.
--LOGIC: Filter rows where account_id matches a given list of values.

SELECT id,
       account_id,
       total_amt_usd
FROM orders
WHERE account_id IN (1001, 1011, 1021);


--QUESTION:
--Find all orders where: account_id is NOT IN (1001, 1011, 1021). Limit to 10 rows.
--LOGIC: Filter rows where account_id matches a given list of values and limit the number of rows.

SELECT id,
       account_id,
       total_amt_usd
FROM orders
WHERE account_id NOT IN (1001, 1011, 1021);


--QUESTION:
--Find all accounts where: name starts with 'C'. Return id, name.
--LOGIC: Filter rows using a text condition on name column.

SELECT id,
       name
FROM accounts
WHERE name LIKE 'C%';


--QUESTION:
--Find the top 10 orders where: total_amt_usd is above 3000 and account_id IN (1001, 1011, 1021). Order by total_amt_usd in descending.
--Return id, account_id, total_amt_usd.
--LOGIC: Apply multiple filters, sort results, and limit output.

SELECT id,
       account_id,
       total_amt_usd
FROM orders
WHERE total_amt_usd > 3000 AND account_id IN (1001, 1011, 1021)
ORDER BY total_amt_usd DESC
LIMIT 10;