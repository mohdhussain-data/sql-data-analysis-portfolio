/*
FILE: 08_Window_Functions.sql

DESCRIPTION:
This file demonstrates analytical SQL techniques using window functions
to perform calculations across related rows while preserving row-level detail.

KEY CONCEPTS:
- Running totals
- Partitioned calculations using OVER()
- Ranking functions (ROW_NUMBER, RANK, DENSE_RANK)
- Window aggregates (SUM, AVG)
- Comparing rows using LAG
- Percentile segmentation using NTILE
*/


/*QUESTION:
Create a running total of standard_amt_usd over order time. 
Return the amount for each row and the cumulative running total.

REWRITE:
1) Final Output: Multiple rows - standard_amt_usd and running_total.
2) Group/Scope: No grouping required.
3) Selection Logic: Order rows by occurred_at and calculate cumulative sum.
4) Final Calculation: SUM(standard_amt_usd) using window function.

LOGIC:
Order the dataset by occurred_at, Use SUM() as a window function to continuously add standard_amt_usd values row by row.*/

SELECT standard_amt_usd,
       SUM(standard_amt_usd)
       OVER (ORDER BY occurred_at) AS running_total
FROM orders;


/*QUESTION:
Create a running total of standard_amt_usd for each account over time.
Return the account_id, order time, order amount, and running total.

REWRITE:
1) Final Output: Multiple rows - account_id, occurred_at, standard_amt_usd, and running_total.
2) Group/Scope: Partition rows by account_id.
3) Selection Logic: Within each account partition, order rows by occurred_at so the running calculation follows chronological order.
4) Final Calculation: Running SUM of standard_amt_usd using window function.

LOGIC:
Split the dataset into account groups using PARTITION BY account_id.
Within each account, order the rows by occurred_at.
Calculate a cumulative SUM of standard_amt_usd that resets when a new account begins.*/

SELECT account_id,
       occurred_at,
       standard_amt_usd,
       SUM(standard_amt_usd)
       OVER (PARTITION BY account_id ORDER BY occurred_at) AS running_total
FROM orders;


/*QUESTION:
Create a running total of standard_amt_usd over order time, but partition the calculation by year.
Return the amount for each row, the truncated year, and the running total within that year.

REWRITE:
1) Final Output: Multiple rows - standard_amt_usd, year, and running_total.
2) Group/Scope: Partition rows by year using DATE_TRUNC.
3) Selection Logic: Order rows by occurred_at within each year.
4) Final Calculation: Running SUM of standard_amt_usd within each year.

LOGIC:
Extract the year from occurred_at using DATE_TRUNC.
Partition the dataset by this year value so each year forms its own window.
Within each year, order rows by occurred_at.
Calculate a cumulative SUM() of standard_amt_usd that resets when the year changes.*/


SELECT standard_amt_usd,
       DATE_TRUNC('year', occurred_at) AS year,
       SUM(standard_amt_usd)
       OVER (PARTITION BY DATE_TRUNC('year', occurred_at) ORDER BY occurred_at) AS running_total
FROM orders;


/*QUESTION:
Number the orders for each account based on order time.

REWRITE:
1) Final Output: Multiple rows - id, account_id, occurred_at, order_number.
2) Group/Scope: Partition the dataset by account_id so numbering restarts for each account.
3) Selection Logic: Order rows by occurred_at within each account.
4) Final Calculation: Use ROW_NUMBER() window function.

LOGIC:
Split the dataset into groups based on account_id using PARTITION BY.
Within each account group, order rows by occurred_at.
Use ROW_NUMBER() to assign sequential numbers to each order. The numbering restarts when a new account begins.*/

SELECT id,
       account_id,
       occurred_at,
       ROW_NUMBER() OVER (PARTITION BY account_id ORDER BY occurred_at) AS order_number
FROM orders;


/*QUESTION:
Rank the total paper ordered for each account from highest to lowest.
Return the id, account_id, total, and the rank of each order within its account.

REWRITE:
1) Final Output: Multiple rows - id, account_id, total, total_rank.
2) Group/Scope: Partition rows by account_id.
3) Selection Logic: Order rows by total in descending order within each account.
4) Final Calculation: Use RANK() window function to assign rankings.

LOGIC:
Split the dataset into account groups using PARTITION BY account_id.
Within each row, order rows by total in descending order.
Apply the RANK() window function to assign a ranking to each order based on total paper ordered.*/


SELECT id,
       account_id,
       total,
       RANK() OVER (PARTITION BY account_id ORDER BY total DESC) AS total_rank
FROM orders;


/*QUESTION:
Rank the total paper ordered for each account using DENSE_RANK, from highest to lowest.
Return id, account_id, total, and the dense rank.

REWRITE:
1) Final Output: Multiple rows - id, account_id, total, desne_rank.
2) Group/Scope: Partition the dataset by account_id.
3) Selection Logic: Order rows by total in descending order within each account.
4) Final Calculation: Use DENSE_RANK() window function.

LOGIC:
Split the dataset into groups using PARTITION BY account_id.
Within each account, order rows by total in descending order.
Apply DENSE_RANK() to assign rankings without skipping numbers when ties occur.*/

SELECT id,
       account_id,
       total,
       DENSE_RANK()
       OVER (PARTITION BY account_id ORDER BY total DESC) AS desne_rank
FROM orders;


/*QUESTION:
For each order, show the order amount and the average order amount for that account.

REWRITE:
1) Final Output: Multiple rows - id, account_id, total_amt_usd, account_avg_order.
2) Group/Scope: Partition rows by account_id.
3) Selection Logic: Calculate average order amount per account using a window aggregate.
4) Final Calculation: AVG(total_amt_usd) over account groups.

LOGIC:
Split the dataset into account groups using PARTITION BY account_id.
Calculate the average order value for each account using AVG() as a window function.
Display this average alongside each individual order.*/

SELECT id,
       account_id,
       total_amt_usd,
       AVG(total_amt_usd)
       OVER (PARTITION BY account_id) AS account_avg_order
FROM orders;


/*QUESTION:
For each order, show the order amount and the total revenue generated by that account.

REWRITE:
1) Final Output: Multiple rows - id, account_id, total_amt_usd, account_total_revenue.
2) Group/Scope: Partition rows by account_id.
3) Selection Logic: Calculate total revenue per account using a window aggregate.
4) Final Calculation: SUM(total_amt_usd) over account groups.

LOGIC:
Split the dataset into groups using PARTITION BY account_id.
Within each group, calculate the total revenue generated by that account using SUM() as a window function.
Display this value alongside each order.*/

SELECT id,
       account_id,
       total_amt_usd,
       SUM(total_amt_usd)
       OVER (PARTITION BY account_id) AS account_total_revenue
FROM orders;


/*QUESTION:
For each order, display the order amount along with the average order value and total revenue for that account using a shared window function.

REWRITE:
1) Final Output: Multiple rows - id, account_id, total_amt_usd, avg_order_value, account_total_reveneue.
2) Group/Scope: Partition rows by account_id.
3) Selection Logic: Define a window alias that partitions rows by account_id and reuse the alias for multiple window calculations.
4) Final Calculation: AVG(total_amt_usd) to compute the average order value per account.
                      SUM(total_amt_usd) to compute total revenue per account.

LOGIC:
Each account can have multiple orders. Instead of repeating the same window definition multiple times,
create a window alias using WINDOW.
Partition the dataset by account_id and reuse this window definition for multiple calculations such as
average order value and total revenue.*/

SELECT id,
       account_id,
       total_amt_usd,
       AVG(total_amt_usd) OVER account_window AS avg_order_value,
       SUM(total_amt_usd) OVER account_window AS account_total_reveneue
FROM orders
WINDOW account_window AS (PARTITION BY account_id);


/*QUESTION:
For each order placed by an account, display the order amount, the previous order amount
from the same account, and calculate the change in order value compared to the previous purchase.

REWRITE:
1) Final Output: Multiple rows - id, account_id, occurred_at, total_amt_usd, previous_order_amount, order_value_change.
2) Group/Scope: Partition rows by account_id.
3) Selection Logic: Order rows chronologically by occurred_at within each account to trach the sequence of purchases.
4) Final Calculation: Use the LAG() window function to retrieve the previous order amount,
and calculate the difference between the current order and the previous order.

LOGIC:
Each account can place multiple orders over time. To analyze purchasing behaviour,
we compare each order amount with the previous order amount for the same account.
First partition the dataset by account_id so that comparisons occur only within the same account.
Then order the rows by occurred_at to maintain the timeline of orders.
Use LAG() function to retrieve the previous order value. Finally subtract the previous order value
from the current order value to calculate how much the purchase order amount increased or decreased.*/

SELECT id,
       account_id,
       occurred_at,
       total_amt_usd,
       LAG(total_amt_usd)
       OVER (PARTITION BY account_id ORDER BY occurred_at) AS previous_order_amount,
       total_amt_usd -
       LAG(total_amt_usd)
       OVER (PARTITION BY account_id ORDER BY occurred_at) AS order_value_change
FROM orders;


/*QUESTION:
Segment orders into revenue quartiles based on their total order value to identify low-value and high-value purchases.

REWRITE:
1) Final Output: Multiple rows - account_id, occurred_at, total_amt_usd, revenue_quartile.
2) Group/Scope: No partition required; segmentation is based on the entire dataset.
3) Selection Logic: Order the dataset by total_amt_usd to rank orders from lowest to highest.
4) Final Calculation: Use the NTILE() window function to divide the ordered dataset into
                      four equal groups representing revenue quartiles.

LOGIC:
Orders vary significantly in value. To analyze how orders are distributed across different revenue levels,
divide the dataset into four equal segments (quartiles) based on the order amount.
First sort the orders by total_amt_usd. Then apply the NTILE(4) window function to assign each order to one of four revenue groups.*/

SELECT account_id,
       occurred_at,
       total_amt_usd,
       NTILE(4)
       OVER (ORDER BY total_amt_usd) AS revenue_quartile
FROM orders;


/*QUESTION:
Identify the highest value order placed by each account.

REWRITE:
1) Final Output: id, account_id, total_amt_usd.
2) Group/Scope: Partition rows by account_id.
3) Selection Logic: Rank orders within each account from highest to lowest order value.
4) Final Calculation: Return only the highest ranked order for each account.

LOGIC:
Each account may have place multiple orders. To determine the most valuable purchase for each account,
first divide the dataset into account groups using PARTITION BY account_id.
Within each group, sort the orders by total_amt_usd in descending order so the largest order appears first.
Use the ROW_NUMBER() window function to assign a ranking to each order within the account group.
Finally filter the results to keep only rows where the rank equals 1,
which represents the highest-value order for each account.*/

WITH ranked_orders AS (SELECT id,
                              account_id,
                              total_amt_usd,
                              ROW_NUMBER()
                              OVER (PARTITION BY account_id ORDER BY total_amt_usd DESC)
                              AS order_rank
                      FROM orders)

SELECT id,
       account_id,
       total_amt_usd
FROM ranked_orders
WHERE order_rank = 1;