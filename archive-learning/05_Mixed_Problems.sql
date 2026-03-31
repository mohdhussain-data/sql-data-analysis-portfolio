/*
FILE: 05_Mixed_Problems.sql

DESCRIPTION:
This file contains analytical SQL problems that combine multiple
concepts learned in earlier sections. These queries demonstrate
how different SQL techniques work together to solve real data
analysis tasks.

KEY CONCEPTS:
- Combining filtering, aggregation, and joins
- Multi-step analytical queries
- Applying multiple SQL techniques in a single problem
- Translating business questions into SQL logic
*/


/*QUESTION:
Which accounts have total revenue greater than the average total revenue per account?

REWRITE:
1) Final Output: Multiple rows - account_id or name.
2) Group/Scope: Group by account.
3) Selection Logic: Keep only accounts whose total revenue is greater than the average total revenue per account.
4) Final Calculation: SUM(total_amt_usd) for each account compared against compared against AVG of those totals.

LOGIC: 
First calculate SUM(total_amt_usd) for each account. Then calculate the average of those totals.
Return only accounts whose total revenue is greater than the average value.*/

SELECT account_id
FROM
       (SELECT account_id,
              SUM(total_amt_usd) AS total_revenue
       FROM orders
       GROUP BY account_id
       ) t
WHERE total_revenue >
              (SELECT AVG(total_revenue)
              FROM
                     (SELECT account_id,
                            SUM(total_amt_usd) AS total_revenue
                     FROM orders
                     GROUP BY account_id
                     ) x
              );


/*QUESTION:
For each region, how many sales reps have total revenue greater than the average sales rep revenue in that same region?

REWRITE:
1) Final Output: Multiple rows - region and count of sales reps.
2) Group/Scope: Group by region and sales rep.
3) Selection Logic: For each region:
                    Calculate total revenue for each sales rep.
                    Calculate the average of these total revenues.
                    Keep only sales reps whose total revenue is greater than their region's average.
4) Final Calculation: COUNT of sales_rep per region after filtering.

LOGIC:
First calculate total revenue for each sales rep inside each region.
Then calculate the average of those revenues for each region.
Keep only the sales reps whose total revenue is greater than their region's average.
Finally, count how many such sales reps exist in each region.*/

WITH t1 AS (SELECT r.name AS region,
                   sr.id AS sales_rep_id,
                   SUM(o.total_amt_usd) AS total_revenue
            FROM region r
            JOIN sales_reps sr ON r.id = sr.region_id
            JOIN accounts a ON a.sales_rep_id = sr.id
            JOIN orders o ON o.account_id = a.id
            GROUP BY r.name, sr.id
            ),
     t2 AS (SELECT region,
                   AVG(total_revenue) AS avg_revenue
            FROM t1
            GROUP BY region
            )
SELECT t1.region,
       COUNT(t1.sales_rep_id) AS num_sales_reps
FROM t1
JOIN t2
ON t1.region = t2.region
WHERE t1.total_revenue > t2.avg_revenue
GROUP BY t1.region;


/*QUESTION:
Which customers placed more orders than the average number of orders per customer?

REWRITE:
1) Final Output: Multiple rows - account_id or name.
2) Group/Scope: Group orders by account.
3) Selection Logic: Calculate count of orders for each customer. Calculate the average of those counts.
                    Keep only customers whose total number of orders is greater than the average number of orders per customer.
4) Final Calculation: COUNT(*) per customer compared against AVG of those counts.

LOGIC:
First calculate number of orders for each customer. Then calculate AVG of those order counts.
Return only customers whose order count is greater than that average.*/

WITH t1 AS (SELECT a.id AS account_id,
                   a.name AS account_name,
                   COUNT(*) AS total_orders
            FROM accounts a
            JOIN orders o
            ON a.id = o.account_id
            GROUP BY a.id, a.name),

     t2 AS (SELECT AVG(total_orders) AS avg_order
            FROM t1)

SELECT t1.account_name
FROM t1
WHERE total_orders >
              (SELECT avg_order
               FROM t2);


/*QUESTION:
Which sales reps manage more accounts than the average number of accounts per sales rep?

REWRITE:
1) Final Output: Multiple rows - sales_rep_id or name.
2) Group/Scope: Group by sales rep.
3) Selection Logic: Calculate count of accounts for each sales rep. Calculate the average of those counts.
                    Keep only sales reps whose total number of accounts is greater than the average number of accounts per sales rep.
4) Final Calculation: COUNT(*) per sales rep compared against AVG of those counts.

LOGIC:
First calculate number of accounts for each sales rep. Then calculate the AVG of those count of accounts.
Return only sales reps whose account count is greater than that average.*/

WITH t1 AS (SELECT sales_rep_id,
                   COUNT(*) AS account_count
            FROM accounts
            GROUP BY sales_rep_id),

     t2 AS (SELECT AVG(account_count) AS avg_account_count
            FROM t1)

SELECT sr.name AS sales_rep_name
FROM t1
JOIN sales_reps sr
ON t1.sales_rep_id = sr.id
WHERE account_count >
              (SELECT avg_account_count
               FROM t2);


/*QUESTION:
Which regions have total revenue greater than the average regional revenue?

REWRITE:
1) Final Output: Multiple rows - region_name.
2) Group/Scope: Group orders by region.
3) Selection Logic: Calculate total revenue for each region. Calculate the average of those totals.
                    Keep only regions whose total revenue is greater than that average.
4) Final Calculation: SUM(total_amt_usd) per region compared against AVG of those totals.

LOGIC:
First calculate SUM(total_amt_usd) for each region. Then calculate AVG of those totals.
Return only regions whose SUM(total_amt_usd) is greater than that average value.*/

WITH t1 AS (SELECT r.name AS region,
                   SUM(o.total_amt_usd) AS total_revenue_per_region
            FROM region r
            JOIN sales_reps sr
            ON r.id = sr.region_id
            JOIN accounts a
            ON a.sales_rep_id = sr.id
            JOIN orders o
            ON o.account_id = a.id
            GROUP BY r.name),

       t2 AS (SELECT AVG(total_revenue_per_region) AS avg_revenue
            FROM t1)

SELECT region
FROM t1
WHERE t1.total_revenue_per_region >
              (SELECT avg_revenue      --Alternate approach could use CROSS JOIN instead of subquery.
               FROM t2);


/*QUESTION:
Which channels have more web events than the average number of web events per channel?

REWRITE:
1) Final Output: Multiple rows - channel name.
2) Group/Scope: Group events by channel.
3) Selection Logic: Calculate count of web events for each channel. Calculate the average of those counts.
                    Keep only channels that have more web events than that average.
4) Final Calculation: COUNT(*) per channel compared against AVG of those counts.

LOGIC:
First calculate number of events COUNT(*) for each channel. Then calculate the AVG of those counts.
Keep only channels that have COUNT(*) greater than that AVG.*/

WITH t1 AS (SELECT channel,
                   COUNT(*) AS event_count
            FROM web_events
            GROUP BY channel),

     t2 AS (SELECT AVG(event_count) AS avg_event
            FROM t1)

SELECT channel
FROM t1
CROSS JOIN t2
WHERE t1.event_count > t2.avg_event;


/*QUESTION:
Which accounts have average order value greater than the overall average order value?

REWRITE:
1) Final Output: Multiple rows - account_name.
2) Group/Scope: Group orders by accounts.
3) Selection Logic: Keep only customers whose average order value is greater than the overall average order value.
4) Final Calculation: AVG(total_amt_usd) for each account compared against the overall average order value.

LOGIC:
First calculate AVG(total_amt_usd) for each account. Calculate the average of the per-account average order values.
Keep only accounts whose AVG(total_amt_usd) is greater than that overall average order value.*/

WITH t1 AS (SELECT o.account_id,
                   a.name AS account_name,
                   AVG(o.total_amt_usd) AS avg_order_value
            FROM orders o
            JOIN accounts a
            ON o.account_id = a.id
            GROUP BY o.account_id, a.name),

     t2 AS (SELECT AVG(avg_order_value) AS overall_avg_order_value
            FROM t1)

SELECT account_name
FROM t1
WHERE t1.avg_order_value >
              (SELECT overall_avg_order_value
               FROM t2);


/*QUESTION:
Which accounts spent more than the customer who bought the most standard_qty paper?

REWRITE:
1) Final Output: Multiple rows - account_name or account_id.
2) Group/Scope: Group orders by account.
3) Selection Logic: Identify the account with the highest SUM(standard_qty). Get that account's total SUM(total_amt_usd).
                    Compare every account's total revenue to that value.
4) Final Calculation: SUM(total_amt_usd) for each account compared against reference value.

LOGIC:
First find the account that purchased the most standard_qty. Then calculate that account's total spending.
Return accounts whose total spending is greater than that amount.*/

WITH t1 AS (SELECT account_id,
                   SUM(standard_qty) AS total_standard
            FROM orders
            GROUP BY account_id
            ORDER BY total_standard DESC
            LIMIT 1),

     t3 AS (SELECT account_id,
                   SUM(total_amt_usd) AS total_spend
            FROM orders
            GROUP BY account_id)

SELECT account_id
FROM t3
WHERE total_spend >
              (SELECT SUM(total_amt_usd)
               FROM orders
               WHERE account_id = (SELECT account_id
                                   FROM t1));


/*QUESTION:
For each region, which sales rep has the highest total revenue?

REWRITE:
1) Final Output: Multiple rows - region, sales_rep_id or name, and total revenue.
2) Group/Scope: Group by region and sales rep to calculate total revenue per rep inside each region.
3) Selection Logic: For each region:
                    Calculate total revenue for every sales rep.
                    Identify the maximum total revenue within that region.
                    Keep only the sales rep whose revenue equals that maximum.
4) Final Calculation: SUM(total_amt_usd) per sales_rep per region. Then, select MAX(total_revenue) inside each region.

LOGIC:
First calculate total revenue for each sales rep inside each region. Then within each region, find the highest revenue.
Return the sales rep whose total revenue equals that highest value.*/

WITH t1 AS (SELECT r.name AS region,
                   sr.name AS sales_rep_name,
                   SUM(o.total_amt_usd) AS total_revenue
            FROM region r
            JOIN sales_reps sr
            ON r.id = sr.region_id
            JOIN accounts a
            ON a.sales_rep_id = sr.id
            JOIN orders o
            ON o.account_id = a.id
            GROUP BY r.name, sr.name),

     t2 AS (SELECT region,
                   MAX(total_revenue) AS max_revenue
            FROM t1
            GROUP BY region)

SELECT t1.region,
       t1.sales_rep_name,
       t1.total_revenue
FROM t1
JOIN t2
ON t1.region = t2.region
AND t1.total_revenue = t2.max_revenue;


/*QUESTION:
For each account, how many web_events occurred for the channel with the most events for that account?

REWRITE:
1) Final Output: Multiple rows - account_id or name, and max_event_count.
2) Group/Scope: Group web_events by account and channel.
3) Selection Logic:For each account:
                   Count events per channel.
                   Find the maximum count.
4) Final Calculation: COUNT(*) per channel. Then MAX(count).

LOGIC:
First calculate how many web events each account has per channel.
Then, for each account, find the maximum of those counts.
Return that maximum value as the number of events for the channel with the most activity.*/

WITH t1 AS (SELECT account_id,
                   channel,
                   COUNT(*) AS event_count
            FROM web_events
            GROUP BY account_id, channel),

     t2 AS (SELECT account_id,
                   MAX(event_count) AS max_event_count
            FROM t1
            GROUP BY account_id)

SELECT account_id,
       max_event_count
FROM t2;


/*QUESTION:
Which accounts have total poster_qty greater than the average poster_qty across all accounts?

REWRITE:
1) Final Output: Multiple rows - account_id or name.
2) Group/Scope: Group by accounts.
3) Selection Logic: First calculate the total SUM(poster_qty) for each account. Then calculate the AVG of these totals.
                    Keep only accounts whose total SUM(poster_qty) is greater than that average.
4) Final Calculation: SUM(poster_qty) per account compared against the extracted average value.

LOGIC:
First calculate the total poster_qty of each account. Then calculate the average of these totals.
Return accounts whose total poster_qty is greater than that average.*/

WITH t1 AS (SELECT o.account_id,
                   a.name AS account_name,
                   SUM(o.poster_qty) AS total_poster
            FROM orders o
            JOIN accounts a
            ON o.account_id = a.id
            GROUP BY o.account_id, a.name)

SELECT account_id,
       account_name
FROM t1
WHERE total_poster >
              (SELECT AVG(total_poster)
               FROM t1);


/*QUESTION:
Which sales reps generated more total revenue than the average of the top 10 sales reps?

REWRITE:
1) Final Output: Multiple rows - sales_rep_id or name.
2) Group/Scope: Group by sales reps.
3) Selection Logic: First calculate the total revenue SUM(total_amt_usd) for each sales rep.
                    Then find the top 10 sales reps by total revenue. Calculate the AVG of these sales reps.
                    Keep only sales reps whose total revenue SUM(total_amt_usd) is greater than that average.
4) Final Calculation: SUM(total_amt_usd) per sales rep compared against the AVG of total revenue of the top reps.

LOGIC:
First calculate the total revenue of each sales rep. Find the top 10 sales reps by total revenue.
Calculate the average of those sales reps. Return reps whose total revenue is greater than that average.*/

WITH t1 AS (SELECT sr.id AS sales_rep_id,
                   sr.name AS sales_rep_name,
                   SUM(o.total_amt_usd) AS total_revenue_per_rep
            FROM sales_reps sr
            JOIN accounts a
            ON sr.id = a.sales_rep_id
            JOIN orders o
            ON o.account_id = a.id
            GROUP BY sr.id, sr.name),

     t2 AS (SELECT total_revenue_per_rep
            FROM t1
            ORDER BY total_revenue_per_rep DESC
            LIMIT 10)

SELECT sales_rep_id,
       sales_rep_name
FROM t1
WHERE total_revenue_per_rep >
              (SELECT AVG(total_revenue_per_rep)
              FROM t2);


/*QUESTION:
Which regions have more accounts than the average number of accounts per region?

REWRITE:
1) Final Output: Multiple rows - region_name, and count of accounts(optional).
2) Group/Scope: Group by region.
3) Seleciton Logic: First calculate number of accounts COUNT(*) per region. Then find the AVG of those accounts.
                    Keep only regioins whose COUNT(*) is greater than that average.
4) Final Calcultion: COUNT(*) per region compared against AVG of the above counts.

LOGIC:
First find the total count of accounts for each region. Calculate the average of that counts.
Return regions that have total number of accounts more than that average value.*/

WITH t1 AS (SELECT r.name AS region,
                   COUNT(*) AS account_count
            FROM region r
            JOIN sales_reps sr
            ON r.id = sr.region_id
            JOIN accounts a
            ON a.sales_rep_id = sr.id
            GROUP BY r.name)

SELECT region
FROM t1
WHERE account_count >
              (SELECT AVG(account_count)
               FROM t1);


/*QUESTION:
Which customers have lifetime average order value greater than the lifetime average order value of the top 5 customers by total revenue?

REWRITE:
1) Final Output: Multiple rows - account_id or name.
2) Group/Scope: Group orders by accounts.
3) Selection Logic: First calculate the total revenue SUM(total_amt_usd) for each account. Find the top 5 customers by total revenue.
                    Calculate the AVG(total_amt_usd) of that top customers.
                    Keep only accounts whose lifetime average AVG(total_amt_usd) is greater than the lifetime AVG of the top customers.
4) Final Calculation: AVG(total_amt_usd) per account compared against lifetime average of those top customers.

LOGIC:
First calculate the total revenue of each account. Find the top 5 customers by total revenue.
Then calculate the lifetime average of that customers. Keep only accounts whose lifetime average order value is greater than the average of that top customers.*/

WITH account_metrics AS (SELECT o.account_id,
                   a.name AS account_name,
                   SUM(o.total_amt_usd) AS total_revenue,
                   AVG(o.total_amt_usd) AS avg_order_value
            FROM orders o
            JOIN accounts a
            ON o.account_id = a.id
            GROUP BY o.account_id, a.name),

     top5_by_revenue AS (SELECT avg_order_value
            FROM account_metrics
            ORDER BY total_revenue DESC
            LIMIT 5)

SELECT account_id,
       account_name
FROM account_metrics
WHERE avg_order_value >
              (SELECT AVG(avg_order_value)
               FROM top5_by_revenue);


/*QUESTION:
Which accounts have total revenue greater than the region's average revenue where they belong?

REWRITE:
1) Final Output: Multiple rows - account_id or account_name.
2) Group/Scope: Group by account.
3) Selection Logic: First calculate total revenue SUM(total_amt_usd) per account.
                    Then calculate the average of account total revenues per region.
                    Join accounts' total revenue to regions' average revenue.
4) Final Calculation: Compare account total vs it's region average.

LOGIC:
First calculate total revenue for each account along with its region.
Then calculate the average of these account revenues for each region.
Return only accounts whose total revenue is greater than their region's average.*/

WITH account_revenue AS (SELECT a.id AS account_id,
                                a.name AS account_name,
                                r.name AS region,
                                SUM(o.total_amt_usd) AS total_revenue
                         FROM accounts a
                         JOIN orders o
                         ON a.id = o.account_id
                         JOIN sales_reps sr
                         ON sr.id = a.sales_rep_id
                         JOIN region r
                         ON r.id = sr.region_id
                         GROUP BY a.id, a.name, r.name),

     region_avg_revenue AS (SELECT region,
                                   AVG(total_revenue) AS avg_revenue
                            FROM account_revenue
                            GROUP BY region)

SELECT ar.account_id,
       ar.account_name
FROM account_revenue ar
JOIN region_avg_revenue rr
ON ar.region = rr.region
WHERE ar.total_revenue > rr.avg_revenue;


/*QUESTION:
For each region, what is the average order value?

REWRITE:
1) Final Output: Multiple rows - region_name, and average order value.
2) Group/Scope: Group orders by region.
3) Selection Logic: Join orders - accounts - sales reps - region.
4) Final Calculation: AVG(total_amt_usd) per region.

LOGIC:
Join orders to their region and compute AVG(total_amt_usd) for each region.*/

SELECT r.name AS region,
       AVG(o.total_amt_usd) AS avg_order_value
FROM region r
JOIN sales_reps sr
ON r.id = sr.region_id
JOIN accounts a
ON a.sales_rep_id = sr.id
JOIN orders o
ON a.id = o.account_id
GROUP BY r.name;


/*QUESTION:
Which sales reps have total revenue greater than their region's average revenue?

REWRITE:
1) Final Output: Multiple rows - sales_rep_id or name.
2) Group/Scope: First group orders by sales reps to get total revenue per rep. Then group that totals by region to get average of rep totals.
3) Selection Logic: First calculate total revenue SUM(total_amt_usd) per sales rep.
                    Then calculate AVG of those rep totals to get average revenue per region.
                    Keep only sales reps whose total revenue SUM(total_amt_usd) is greater than average revenue per region.
4) Final Calculation: SUM(total_amt_usd) per rep compared against AVG of their region.

LOGIC:
First calcualate total revenue per sales rep. Then calculate average of those rep totals and group by region.
Return sales reps whose total revenue is greater than their region's average revenue.*/

WITH rep_revenue AS (SELECT sr.id AS sales_rep_id,
                            sr.name AS sales_rep_name,
                            r.name AS region,
                            SUM(o.total_amt_usd) AS rep_total_revenue
                     FROM region r  
                     JOIN sales_reps sr
                     ON r.id = sr.region_id
                     JOIN accounts a
                     ON a.sales_rep_id = sr.id
                     JOIN orders o
                     ON o.account_id = a.id
                     GROUP BY sr.id, sr.name, r.name),

     region_avg AS (SELECT region,
                   AVG(rep_total_revenue) AS avg_revenue_per_region
            FROM rep_revenue
            GROUP BY region)

SELECT rr.sales_rep_id,
       rr.sales_rep_name
FROM rep_revenue rr
JOIN region_avg ra
ON rr.region = ra.region
WHERE rr.rep_total_revenue > ra.avg_revenue_per_region;


/*QUESTION:
Which customers have more web events than the customer with the highest total revenue?

REWRITE:
1) Final Output: Multiple rows - account_id or name.
2) Group/Scope: Group events by accounts.
3) Selection Logic: Find customer with highest total revenue.
                    Get that customer's web event count.
                    Compare all customers' event counts to that value.
4) Final Calculation: COUNT(*) per account.

LOGIC:
Find the customer who spent the most. Find how many web events that customer has.
Return customers who have more web events than that number.*/

WITH top_customer AS (SELECT account_id,
                             SUM(total_amt_usd) AS total_revenue
                     FROM orders
                     GROUP BY account_id
                     ORDER BY total_revenue DESC
                     LIMIT 1),

     events_per_account AS (SELECT account_id,
                                   COUNT(*) AS event_count
                            FROM web_events
                            GROUP BY account_id)

SELECT account_id
FROM events_per_account
WHERE event_count >
              (SELECT event_count
               FROM events_per_account
               WHERE account_id = (SELECT account_id
                                   FROM top_customer));


/*QUESTION:
Which channels generate more total orders than the average channel?

REWRITE:
1) Final Output: Multiple rows - channel name.
2) Group/Scope: Group orders by channel.
3) Selection Logic: First calculate total number of orders COUNT(*) per channel. Calculate the AVG of those counts.
                    Keep only channels whose count > average.
4) Final Calculation: COUNT(*) per channel.

LOGIC:
Count how many orders each channel has. Find the average of these counts.
Return channels whose order count is greater than the average.*/

WITH total_orders AS (SELECT w.channel,
                             COUNT(*) AS total_orders_per_channel
                      FROM web_events w
                      JOIN orders o
                      ON w.account_id = o.account_id
                      GROUP BY w.channel),

     avg_orders AS (SELECT AVG(total_orders_per_channel) AS avg_order
            FROM total_orders)

SELECT channel
FROM total_orders
WHERE total_orders_per_channel >
        (SELECT avg_order
         FROM avg_orders);


/*QUESTION:
Which accounts have both:
                         total revenue above average and
                         total orders above average.

REWRITE:
1) Final Output: Multiple rows - account_id or name.
2) Group/Scope: Group by account.
3) Selection Logic: First Calculate SUM(total_amt_usd) per account. Then calculate COUNT(*) per account to find total orders per account.
                    Calculate the AVG of those total reveneues and total counts of orders.
                    Keep only accounts whose total revenue and counts of orders > their average values.
4) Final Calcualtion: SUM(total_amt_usd) per account and COUNT(*) per account.

LOGIC:
Compute total revenue per account. Find how many orders each account has.
Find the average of both: total revenue and order counts.
Return accounts whose total revenue and order count both > their average values.*/

WITH total_revenue_total_orders AS (SELECT o.account_id,
                                          a.name AS account_name,
                                          SUM(o.total_amt_usd) AS total_revenue,
                                          COUNT(*) AS total_orders
                                   FROM orders o
                                   JOIN accounts a
                                   ON o.account_id = a.id
                                   GROUP BY o.account_id, a.name),

     avg_revenue_avg_orders AS (SELECT AVG(total_revenue) AS avg_revenue,
                                      AVG(total_orders) AS avg_order
                               FROM total_revenue_total_orders)

SELECT account_id,
       account_name
FROM total_revenue_total_orders t
CROSS JOIN avg_revenue_avg_orders a
WHERE t.total_revenue > a.avg_revenue
AND t.total_orders > a.avg_order;