/*
FILE: 03_Joins.sql

DESCRIPTION:
This file demonstrates how relational tables are combined using joins to
analyze relationships between datasets.

KEY CONCEPTS:
- INNER JOIN
- LEFT JOIN
- Joining multiple tables
- Relationship-based data analysis
*/


/*QUESTION:
Show order id, account name and total_amt_usd.

REWRITE:
1) Final Output: Multiple rows - order_id, account_name, total_amt_usd.
2) Group/Scope: No grouping required.
3) Selection Logic: Join orders table with accounts table using account_id.
4) Final Calculation: Select order id, account name and total_amt_usd.

LOGIC: Start from orders. Join accounts using account_id. Select order id, account name and total_amt_usd.*/

SELECT o.id AS order_id,
       a.name AS account_name,
       o.total_amt_usd
FROM orders o
JOIN accounts a
ON o.account_id = a.id;


/*QUESTION:
Show account name and website for each account.

REWRITE:
1) Final Output: Multiple rows - account name and website.
2) Group/Scope: No grouping required.
3) Selection Logic: Use accounts table (no join required).
4) Final Calculation: Select account name, website.

LOGIC: Use accounts table. Select account name, website.*/

SELECT name AS account_name,
       website
FROM accounts;


/*QUESTION:
Show order_id, account name and occurred_at.

REWRITE:
1) Final Output: Multiple rows - order_id, account name, and occurred_at.
2) Group/Scope: No grouping required.
3) Selection Logic: Join orders table with accounts table using account_id.
4) Final Calculation: Select order_id, account_name and occurred_at.

LOGIC: Start from orders. Join accounts using account_id. Select order_id, account_name, occurred_at.*/

SELECT o.id AS order_id,
       a.name AS account_name,
       o.occurred_at
FROM orders o
JOIN accounts a
ON o.account_id = a.id;


/*QUESTION:
Show sales_rep name and the accounts they manage.

REWRITE:
1) Final Output: Multiple rows - sales_rep name, and account name.
2) Group/Scope: No grouping required.
3) Selection Logic: Join sales_reps table with accounts table using sales_rep_id.
4) Final Calculation: Select sales_rep_name, account_name.

LOGIC: Start from sales_reps. Join accounts using sales_rep_id. Select sales_rep_name, account name.*/

SELECT sr.name AS sales_rep_name,
       a.name AS account_name
FROM sales_reps sr
JOIN accounts a
ON sr.id = a.sales_rep_id;


/*QUESTION:
Show region name and sales_rep name.

REWRITE:
1) Final Output: Multiple rows - region_name and sales_rep_name.
2) Group/Scope: No grouping required.
3) Selection Logic: Join region table with sales_reps table using region_id.
4) Final Calculation: Select region_name and sales_rep_name.

LOGIC: Start from region. Join sales_reps using region_id. Select region_name and sales_rep_name.*/

SELECT r.name AS region_name,
       sr.name AS sales_rep_name
FROM region r
JOIN sales_reps sr
ON r.id = sr.region_id;


/*QUESTION:
Show order_id, account_name and sales_rep name.

REWRITE:
1) Final Output: Multiple rows - order_id, account_name and sales_rep_name.
2) Group/Scope: No grouping required.
3) Selection Logic: Join orders table with accounts table using account_id.
                    Then join sales_reps table with accounts table using sales_rep_id.
4) Final Calculation: Select order_id, account_name and sales_rep_name.

LOGIC: Start from orders. Join accounts using account_id. Join sales_reps using sales_rep_id.
       Select order_id, account_name, and sales_rep_name.*/

SELECT o.id AS order_id,
       a.name AS account_name,
       sr.name AS sales_rep_name
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps sr
ON sr.id = a.sales_rep_id;


/*QUESTION:
Show order_id, account_name and region_name.

REWRITE:
1) Final Output: Multiple rows - order_id, account_name and region_name.
2) Group/Scope: No grouping required.
3) Selection Logic: Join orders table with accounts table using account_id.
                    Join sales_reps table with accounts table using sales_rep_id.
                    Join region table with sales_reps table using region_id.
4) Final Calculation: Select order_id, account_name, region_name.

LOGIC: Start from orders. Join accounts using account_id. Join sales_reps using sales_rep_id.
       Join region using region_id. Select order_id, account_name and region_name.*/

SELECT o.id AS order_id,
       a.name AS account_name,
       r.name AS region_name
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps sr
ON sr.id = a.sales_rep_id
JOIN region r
ON r.id = sr.region_id;


/*QUESTION:
Show account name and region name.

REWRITE:
1) Final Output: Multiple rows - account_name and region_name.
2) Group/Scope: No grouping required.
3) Selection Logic: Join accounts table with sales_reps table using sales_rep_id.
                    Join sales_reps table with region table using region_id.
4) Final Calculation: Select account_name and region_name.

LOGIC: Start from accounts. Join sales_reps using sales_rep_id. Join region using region_id.
                            Select account_name and region_name.*/

SELECT a.name AS account_name,
       r.name AS region_name
FROM accounts a
JOIN sales_reps sr
ON a.sales_rep_id = sr.id
JOIN region r
ON sr.region_id = r.id;


/*QUESTION:
Show web_event id, account name and channel.

REWRITE:
1) Final Output: Multiple rows - web_event_id, account_name and channel.
2) Group/Scope: No grouping required.
3) Selection Logic: Join web_events table with accounts table using account_id.
4) Final Calculation: Select web_event_id, account_name and channel.

LOGIC: Start from web_events. Join accounts using account_id. Select web_event_id, account_name and channel.*/

SELECT w.id AS web_event_id,
       a.name AS account_name,
       w.channel
FROM web_events w
JOIN accounts a
ON w.account_id = a.id;


/*QUESTION:
Show account name, sales_rep name and region_name.

REWRITE:
1) Final Output: Multiple rows - account_name, sales_rep_name and region_name.
2) Group/Scope: No grouping required.
3) Selection Logic: Join accounts table with sales_reps table using sales_rep_id.
                    Join sales_reps table with region table using region_id.
4) Final Calculation: Select account_name, sales_rep_name and region_name.

LOGIC: Start from accounts. Join sales_reps using sales_rep_id.
       Join region using region_id. Select account_name, sales_rep_name and region_name.*/

SELECT a.name AS account_name,
       sr.name AS sales_rep_name,
       r.name AS region_name
FROM accounts a
JOIN sales_reps sr
ON a.sales_rep_id = sr.id
JOIN region r
ON sr.region_id = r.id;

/*QUESTION:
Show order_id, account_name and standard_qty.

REWRITE:
1) Final Output: Multiple rows - order_id, account_name and standard_qty.
2) Group/Scope: No grouping required.
3) Selection Logic: Join orders table with accounts table using account_id.
4) Final Calculation: Select order_id, account_name and standard_qty.

LOGIC: Start from orders. Join accounts using account_id. Select order_id, account_name and standard_qty.*/

SELECT o.id AS order_id,
       a.name AS account_name,
       o.standard_qty
FROM orders o
JOIN accounts a
ON o.account_id = a.id;


/*QUESTION:
Show order_id, account_name and poster_qty.

REWRITE:
1) Final Output: Multiple rows - order_id, account_name and poster_qty.
2) Group/Scope: No grouping required.
3) Selection Logic: Join orders table with accounts table using account_id.
4) Final Calculation: Select order_id, account_name and poster_qty.

LOGIC: Start from orders. Join accounts using account_id. Select order_id, account_name and poster_qty.*/

SELECT o.id AS order_id,
       a.name AS account_name,
       o.poster_qty
FROM orders o
JOIN accounts a
ON o.account_id = a.id;


/*QUESTION:
Show account name and total number of orders.

REWRITE:
1) Final Output: Multiple rows - account_name and num_orders.
2) Group/Scope: Group by account_name.
3) Selection Logic: Join accounts table with orders table using account_id.
4) Final Calculation: Count(*) to calculate number of orders per account.

LOGIC: Start from accounts. Join orders using account_id. COUNT(*) to calculate total number of orders. Select account_name and num_orders.*/

SELECT a.name AS account_name,
       COUNT(*) AS num_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name;


/*QUESTION:
Show sales_rep name and total number of accounts they manage.

REWRITE:
1) Final Output: Multiple rows - sales_rep_name and num_accounts.
2) Group/Scope: Group by sales_rep name.
3) Selection Logic: Join sales_reps table with accounts table using sales_rep_id.
4) Final Calculation: COUNT(*) to calculate number of accounts managed by each sales_rep.

LOGIC: Start from sales_reps. Join accounts using sales_rep_id. Group by sales_rep_name. COUNT(*) to get number of accounts per sales_rep.*/

SELECT sr.name AS sales_rep_name,
       COUNT(*) AS num_accounts
FROM sales_reps sr
JOIN accounts a
ON sr.id = a.sales_rep_id
GROUP BY sr.name;


/*QUESTION:
Show region name and total number of sales reps.

REWRITE:
1) Final Output: Multiple rows - region_name and num_sales_reps.
2) Group/Scope: Group by region_name.
3) Selection Logic: Join region table with sales_reps table using region_id.
4) Final Calculation: COUNT(*) to calculate number of sales reps for each region.

LOGIC: Start from region. Join sales_reps using region_id. Group by region_name. COUNT(*) to get number of sales_reps per region.*/

SELECT r.name AS region,
       COUNT(*) AS num_sales_reps_per_region
FROM region r
JOIN sales_reps sr
ON r.id = sr.region_id
GROUP BY r.name;


/*QUESTION:
Show region name and total revenue generated in each region.

REWRITE:
1) Final Output: Multiple rows - region_name and total_revenue_per_region.
2) Group/Scope: Group by region_name.
3) Selection Logic: Join region table with sales_reps table using region_id. Join sales_reps table with accounts table using sales_rep_id.
                    Join accounts table with orders table using account_id.
4) Final Calculation: SUM(o.total_amt_usd) to calculate total revenue for each region.

LOGIC: Start from region. Join sales_reps using region_id. Join accounts using sales_rep_id.
       Join orders using account_id. Group by region_name. SUM(o.total_amt_usd) to get total revenue for each region.*/

SELECT r.name AS region,
       SUM(o.total_amt_usd) AS total_revenue
FROM region r
JOIN sales_reps sr
ON r.id = sr.region_id
JOIN accounts a
ON sr.id = a.sales_rep_id
JOIN orders o
ON a.id = o.account_id
GROUP BY r.name;