/*
FILE: 04_Subqueries.sql

DESCRIPTION:
This file contains queries that use subqueries to perform multi-step
analysis by generating intermediate results within nested queries.

KEY CONCEPTS:
- Subqueries in WHERE clauses
- Subqueries in SELECT statements
- Nested aggregations
- Multi-step analytical queries
*/


--QUESTION:
--Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

--REWRITE:
--1) Final Output: Multiple rows - one row per region, showing the sales_rep name with region.
--2) Group/Scope: Group sales by region and sales_rep.
--3) Selection Logic: For each region, identify the sales_rep whose total sales SUM(total_amt_usd) is the highest among all sales_reps in that region.
--4) Final Calculation: Calculate total sales per sales_rep per region using SUM(total_amt_usd), then select the maximum total per region and return the corresponding sales_rep.

--LOGIC:
--First calculate total sales for each sales rep in each region.
--Then, for each region, find the highest total sales and the return the sales rep who achieved it.

SELECT
    rep_name,
    region,
    total_sales
FROM (
    SELECT
        sr.name AS rep_name,
        r.name AS region,
        SUM(o.total_amt_usd) AS total_sales
    FROM sales_reps sr
    JOIN region r ON sr.region_id = r.id
    JOIN accounts a ON a.sales_rep_id = sr.id
    JOIN orders o ON o.account_id = a.id
    GROUP BY sr.name, r.name
) t
WHERE total_sales = (
    SELECT MAX(total_sales)
    FROM (
        SELECT
            r.name AS region,
            SUM(o.total_amt_usd) AS total_sales
        FROM sales_reps sr
        JOIN region r ON sr.region_id = r.id
        JOIN accounts a ON a.sales_rep_id = sr.id
        JOIN orders o ON o.account_id = a.id
        WHERE r.name = t.region
        GROUP BY r.name, sr.name
    ) sub
);


--QUESTION:
--For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?

--REWRITE:
--1) Final Output: One number - the total count of orders .
--2) Group/Scope: Group sales by region to determine which region has the highest total sales.
--3) Selection Logic: Identify the single region whose total sales SUM(total_amt_usd) is the largest compared to all other regions.
--4) Final Calculation: Count the total number of orders that were placed in that top selling region.

--LOGIC:
--First calculate total sales per region. Then, find the region with the highest total sales.
--Then count how many orders were placed in that region.

SELECT r.name region, COUNT(o.total) ord_count
FROM region r
JOIN sales_reps sr ON r.id = sr.region_id
JOIN accounts a ON a.sales_rep_id = sr.id
JOIN orders o ON o.account_id = a.id
GROUP BY 1
HAVING SUM(o.total_amt_usd) =
    (SELECT MAX(total_sales) max_sales
    FROM 
        (SELECT r.name region, SUM(o.total_amt_usd) total_sales
        FROM region r
        JOIN sales_reps sr ON sr.region_id = r.id
        JOIN accounts a ON a.sales_rep_id = sr.id
        JOIN orders o ON o.account_id = a.id
        GROUP BY 1
        )
    );


--QUESTION:
--How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?

--REWRITE:
--1)Final Output: One number - total count of accounts.
--2)Group/Scope: Group orders by account to calculate lifetime totals per account.
--3)Selection Logic: First identify the single account that has purchased the highest total standard_qty paper over their lifetime.
--                  Then, compare all other accounts' total purchases to this account total purchases.
--4)Final Calculation: Count how many accounts have a higher total purchase amount SUM(total_amt_usd) than the reference account identified above.

--LOGIC:
--Find the account that bought the most standard paper overall.
--Get that account's total spending, then count how many other accounts spent more than that amount.

SELECT COUNT(*) AS num_accounts
FROM
    (SELECT o.account_id
    FROM orders o
    GROUP BY 1
    HAVING SUM(o.total_amt_usd) >
        (SELECT SUM(o.total_amt_usd)
            FROM orders o
            WHERE o.account_id =
                (SELECT o.account_id
                FROM orders o
                GROUP BY 1
                ORDER BY SUM(o.standard_qty) DESC
                LIMIT 1
                )
        )
    );


--QUESTION:
--For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?

--REWRITE:
--1) Final Output: Multiple rows - one row per channel
--2) Group/Scope: Group by web_events by channel
--3) Selection Logic: Identify the customer that spent the most in total over their lifetime SUM(total_amt_usd)
--4) Final Calculation: Count web_events per channel for that customer.

--LOGIC: Calculate total spent per customer, find the customer with the highest total spent(total_amt_usd).
--       Return the number of web_events placed by that customer for each channel.

SELECT w.account_id,
       w.channel,
       COUNT(*) num_events
FROM web_events w
WHERE w.account_id =
    (SELECT id
    FROM
        (SELECT a.id,
            SUM(o.total_amt_usd) total_spent
        FROM accounts a
        JOIN orders o
        ON a.id = o.account_id
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 1)
    )
GROUP BY 1,2
ORDER BY 3 DESC;


--QUESTION:
--What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?

--REWRITE:
--1) Final Output: One number-One row (average amount)
--2) Group/Scope: Group total_amt_usd by accounts to find the top 10
--3) Selection Logic: Identify the top 10 total spending accounts (total_amt_usd)
--4) Final Calculation: Calculate AVG amount for that accounts that we identified above

--LOGIC: First, identify the top 10 accounts SUM(total_amt_usd).
--       Then, calculate the combined average for that accounts.

SELECT AVG(total_spent)
FROM
    (SELECT a.id,
            SUM(o.total_amt_usd) total_spent
    FROM accounts a
    JOIN orders o ON a.id = o.account_id
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 10);


--QUESTION:
--What is the lifetime average amount spent in terms of **total_amt_usd**, including only the companies that spent more per order, on average, than the average of all orders.

--REWRITE:
--1) Final Output: One number: lifetime average total_amt_usd across selected companies
--2) Group/Scope: Group orders by account_id to calculate per-company averages
--3) Selection Logic: First compute the overall average order value across all orders.
--                    Then identify the companies whose average order value is greater than this overall average
--4) Final Calculation: Compute the average of total_amt_usd for only those qualifying companies.

--LOGIC: First calculate the overall average order value.
--       Then find companies whose average order value exceeds this.
--       Finally, compute the lifetime average spending for only those companies.

SELECT AVG(avg_per_account) avg_amt
FROM
    (SELECT o.account_id,
        AVG(o.total_amt_usd) avg_per_account
    FROM orders o
    GROUP BY 1
    HAVING AVG(o.total_amt_usd) >
        (SELECT AVG(o.total_amt_usd) overall_avg
        FROM orders o
        )
    );


/*QUESTION:
Which accounts have a total revenue greater than the average total revenue per account?

REWRITE:
1) Final Output: Multiple rows - account_id whose total revenue is above average.
2) Group/Scope: Group orders by account_id to calculate total revenue per account.
3) Selection Logic: Keep only accounts whose total revenue is greater than average total revenue per account.
4) Final Calculation: SUM of total_amt_usd for each account, compared against AVG of those totals.

LOGIC: First calculate total revenue for each account. Then calculate the average of these total revenues.
       Return only the accounts whose total revenue is greater than that average.*/

SELECT account_id
FROM orders
GROUP BY account_id
HAVING SUM(total_amt_usd) >
    (SELECT AVG(total_revenue)
    FROM
        (SELECT account_id,
            SUM(total_amt_usd) AS total_revenue
        FROM orders
        GROUP BY account_id
        ) t
    );


/*QUESTION:
Which sales reps have total revenue greater than the average revenue of all sales reps?

REWRITE:
1) Final Output: Multiple rows - sales_rep_name.
2) Group/Scope: Group orders by sales_rep to calculate total revenue per rep.
3) Selection Logic: Keep only sales_reps whose total revenue is greater than the average total revenue per sales rep.
4) Final Calculation: SUM(total_amt_usd) per rep compared against AVG of those totals.

LOGIC: First calculate total revenue for each sales_rep. Then calculate the average of these totals.
       Return only sales reps whose total revenue is greater than that average.*/

SELECT sr.id AS sales_rep_id
       sr.name AS sales_rep_name
FROM sales_reps sr
JOIN accounts a
ON sr.id = a.sales_rep_id
JOIN orders o
ON o.account_id = a.id
GROUP BY sr.id
HAVING SUM(o.total_amt_usd) >
    (SELECT AVG(total_revenue_per_rep) AS avg_total_revenue
    FROM
        (SELECT sr.id,
            SUM(o.total_amt_usd) AS total_revenue_per_rep
        FROM sales_reps sr
        JOIN accounts a
        ON sr.id = a.sales_rep_id
        JOIN orders o
        ON o.account_id = a.id
        GROUP BY sr.id
        )
    );


/*QUESTION:
Which accounts placed more orders than the average number of orders per account?

REWRITE:
1) Final Output: Multiple rows - account_name.
2) Group/Scope: Group orders by account.
3) Selection Logic: Keep only accounts whose number of orders is greater than average number of orders per account.
4) Final Calculation: COUNT(*) per account compared against AVG of those counts.

LOGIC: First calculate number of orders for each account. Then calculate average of these order counts.
       Return only accounts whose order count is greater than than that average.*/

SELECT a.name AS account_name
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
HAVING COUNT(*) >
    (SELECT AVG(total_orders_per_account)
    FROM
        (SELECT o.account_id,
                COUNT(*) AS total_orders_per_account
        FROM orders o
        GROUP BY o.account_id
        ) t
    );


/*QUESTION:
Which regions have total revenue greater than the average regional revenue?

REWRITE:
1) Final Output: Multiple rows - region_name.
2) Group/Scope: Group orders by region.
3) Selection Logic: Keep only regions whose total revenue is greater than the average regional revenue.
4) Final Calcualtion: SUM(total_amt_usd) per region compared against AVG of that revenue.

LOGIC: First calculate total revenue for each region. Then calculate average of these total revenue.
       Return only regions whose total revenue is greater than that average revenue.*/

SELECT r.name AS region_name
FROM region r
JOIN sales_reps sr
ON r.id = sr.region_id
JOIN accounts a
ON sr.id = a.sales_rep_id
JOIN orders o
ON a.id = o.account_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) >
       (SELECT AVG(total_revenue_per_region)
       FROM
              (SELECT r.id,
                     SUM(o.total_amt_usd) AS total_revenue_per_region
              FROM region r
              JOIN sales_reps sr
              ON r.id = sr.region_id
              JOIN accounts a
              ON sr.id = a.sales_rep_id
              JOIN orders o
              ON a.id = o.account_id
              GROUP BY r.id
              ) t
       );


/*QUESTION:
Which customers have an average order value greater than the average order value of the top 10 customers by total revenue?

REWRITE:
1) Final Output: Multiple rows - account_id.
2) Group/Scope: Group orders by account_id.
3) Selection Logic: First find top 10 customers by SUM(total_amt_usd).
                    For those 10 customers calculate AVG(total_amt_usd).
                    Compare every customer's AVG(total_amt_usd) against that value.
4) Final Calculation: AVG(total_amt_usd) per account compared to average of top 10 customers' AVG(total_amt_usd).

LOGIC: Find top 10 customers by total revenue. Calculate their average order values. Take average of those values.
       Return customers whose average order value is higher.*/

SELECT o.account_id
FROM orders o
GROUP BY o.account_id
HAVING AVG(o.total_amt_usd) >
       (SELECT AVG(avg_order_value)
       FROM
              (SELECT account_id,
                     AVG(total_amt_usd) AS avg_order_value
              FROM orders
              GROUP BY account_id
              ORDER BY SUM(total_amt_usd) DESC
              LIMIT 10
              )
       );


/*QUESTION:
For each region, how many sales reps have total revenue greater than the average sales rep revenue in that same region?

REWRITE:
1) Final Output: Multiple rows - region_name and count_of_sales_reps.
2) Group/Scope: Group sales by region and sales_rep to calculate total revenue per sales_rep per region.
3) Selection Logic: For each region:
                    Calculate total revenue for each sales_rep.
                    Calculate the average of these total revenues.
                    Keep only sales_reps whose total revenue is greater than their region's average.
4) Final Calculation: COUNT of sales_rep per region after filtering.

LOGIC:
First Calculate total revenue for each sales_rep inside each region.
Then calculate the average of those revenues for each region.
Keep only the sales_reps whose total revenue is greater than their region's average.
Finally, count how many such sales reps exist in each region.*/

SELECT region,
       COUNT(sales_rep_id) AS num_sales_reps
FROM
       (SELECT t.region,
              t.sales_rep_id
       FROM
              (SELECT r.name AS region,
                     sr.id AS sales_rep_id,
                     SUM(o.total_amt_usd) AS total_revenue
              FROM region r
              JOIN sales_reps sr
              ON sr.region_id = r.id
              JOIN accounts a
              ON a.sales_rep_id = sr.id
              JOIN orders o
              ON o.account_id = a.id
              GROUP BY r.name, sr.id
              ) t
       JOIN
                     (SELECT region,
                            AVG(total_revenue) AS avg_revenue
                     FROM
                            (SELECT r.name AS region,
                                   sr.id AS sales_rep_id,
                                   SUM(o.total_amt_usd) AS total_revenue
                            FROM region r
                            JOIN sales_reps sr
                            ON r.id = sr.region_id
                            JOIN accounts a
                            ON a.sales_rep_id = sr.id
                            JOIN orders o
                            ON o.account_id = a.id
                            GROUP BY r.name, sr.id
                            ) x
                     GROUP BY region
                     ) avg_table
       ON t.region = avg_table.region
       WHERE t.total_revenue > avg_table.avg_revenue
       ) final
GROUP BY region;


/*QUESTION:
Which accounts have total standard_qty greater than the total standard_qty of the account with the highest poster_qty?

REWRITE:
1) Final Output: Multiple rows - account_id.
2) Group/Scope: Group orders by account_id.
3) Selection Logic: First find the account with the highest poster_qty SUM(poster_qty).
                    Find the total standard_qty of that account SUM(standard_qty).
                    Compare every account's SUM(standard_qty) against that value.
4) Final Calculation: SUM(standard_qty) per account to compared to total standard_qty of the extracted account.

LOGIC: Find account with the highest poster_qty. Calculate total standard_qty of that account.
       Return accounts whose total standard_qty is greater than that value.*/

SELECT account_id
FROM orders
GROUP BY account_id
HAVING SUM(standard_qty) >
       (SELECT total_standard
       FROM
              (SELECT account_id,
                     SUM(poster_qty) AS total_poster,
                     SUM(standard_qty) AS total_standard
              FROM orders
              GROUP BY account_id
              ORDER BY total_poster DESC
              LIMIT 1
              ) t
       );


/*QUESTION:
Which sales reps manage more accounts than the average number of accounts per sales_rep?

REWRITE:
1) Final Output: Multiple rows - sales_rep_id (or) sales_rep_name.
2) Group/Scope: Group by sales_rep
3) Selection Logic: First find the total number of accounts managed by each sales rep-COUNT(*).
                    Calculate the average of that count.
                    Compare every sales reps COUNT(*) against that value.
4) Final Calculation: COUNT(*) per sales_rep compared to the overall average value.

LOGIC: COUNT(*) per sales rep to calculate the total number of accounts managed by each sales_rep.
       Calculate the average of that counts. Return sales reps who manage total accounts more than that value.*/

SELECT sales_rep_id
FROM accounts
GROUP BY sales_rep_id
HAVING COUNT(*) >
       (SELECT AVG(count_of_accounts) AS avg_num_acc
       FROM
              (SELECT sales_rep_id,
                     COUNT(*) AS count_of_accounts
              FROM accounts
              GROUP BY sales_rep_id
              ) t
       );


/*QUESTION:
Which channels have more web events than the average number of web events per channel?

REWRITE:
1) Final Output: Multiple rows - channel name.
2) Group/Scope: Group by channel.
3) Selection Logic: First find the total number of web events for each channel-COUNT(*).
                    Calculate the average of that count.
                    Compare every channels COUNT(*) against that value.
4) Final Calculation: COUNT(*) per channel compared to the overall average value.

LOGIC: COUNT(*) per channel to calculate the total number of web events per channel. Calculate the average of that counts.
       Return channels that have more web events than that value.*/

SELECT channel
FROM web_events
GROUP BY channel
HAVING COUNT(*) >
       (SELECT AVG(event_count)
       FROM
              (SELECT channel,
                     COUNT(*) AS event_count
              FROM web_events
              GROUP BY channel
              ) t
       );