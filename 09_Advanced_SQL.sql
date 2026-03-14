/*QUESTION:
Identify relationship gaps between accounts and sales representatives.
Return all accounts and sales reps, including:
- accounts that do not currently have a sales representative assigned.
- sales representatives who do not manage any accounts.
This helps management detect underutilized sales reps and accounts without coverage.

REWRITE:
1) Final Output: Multiple rows showing accounts and sales rep relationships.
2) Group/Scope: No grouping required. Row-level relationship comparison.
3) Selection Logic: Perform a FULL OUTER JOIN between accounts and sales_reps using sales_rep_id.
4) Final Calculation: Return account_id, account_name, sales_rep_id, and sales_rep_name.
                      Unmatched rows reveal accounts without reps and reps without accounts.

LOGIC:
Accounts and sales reps are connected through sales_rep_id. However, some accounts may not yet have an assigned sales rep.
Similarly, some sales reps may not currently manage any accounts. A FULL OUTER JOIN allows us to keep:
- all accounts
- all sales reps
Matched rows show valid relationships. Unmatched rows expose coverage gaps in the sales organization.*/

SELECT a.id AS account_id,
       a.name AS account_name,
       sr.id AS sales_rep_id,
       sr.name AS sales_rep_name
FROM accounts a
FULL OUTER JOIN sales_reps sr
ON a.sales_rep_id = sr.id
WHERE a.id IS NULL OR sr.id IS NULL;

-- Note: In the Parch & Posey dataset this query returns no rows because the data is clean.
-- However, this pattern is useful for detecting orphan records in real production datasets.


/*QUESTION:
Identify high-value orders compared to the average order value of the entire dataset.
Return all orders where the order amount is greater than the overall average order amount.
Show the order id, account id, order amount, and the overall average for comparison.

REWRITE:
1) Final Output: Multiple rows - order_id, account_id, total_amt_usd, and avg_order_value.
2) Group/Scope: No grouping in the final result. Each order is evaluated individually.
3) Selection Logic: Compute the overall average order value using a subquery.
                    Join each order to this average using a comparison operator (>).
4) Final Calculation: Compare orders.total_amt_usd against the calculated average order value.

LOGIC:
First calculate the overall average order value from the orders table.
Then compare each individual order to the value.*/

SELECT o.id AS order_id,
       o.account_id,
       o.total_amt_usd,
       avg_table.avg_order_value
FROM orders o
CROSS JOIN
       (SELECT AVG(total_amt_usd) AS avg_order_value
       FROM orders
       ) avg_table
ON o.total_amt_usd > avg_table.avg_order_value;


/*QUESTION:
Analyze short term user engagement by identifying web events that occur shortly after another event from the same account.
Return pairs of web events where the second event occurs within 1 day after the first event for the same account.
Include the account_id, timestamps of both events, and the marketing channel used for each event.

REWRITE:
1) Final Output: Multiple rows - account_id, first_event_time, first_channel, second_event_time, and second_channel.
2) Group/Scope: Compare web events within the same account.
3) Selection Logic: Perform a SELF JOIN on the web_events table so that each event can be compared with later events from the same account.
4) Final Calculation: Filter the results so that the second event occurs:
                      after the first event.
                      within 1 day of the first event.

LOGIC:
The web_events table records multiple interactions for each account over time.
To analyze quick follow-up engagement:
1. Create two instances of the web_events table.
       One instance represents the first event.
       The other represents the second event occurring shortly after.
2. Match rows where:
       same account
       second event happened later
       second event occurred within 1 day.
3. This reveals sequential web interactions that occur close together, which may indicate strong engagement or
strong marketing channle engagement.*/

SELECT w1.account_id,
       w1.occurred_at AS first_event_time,
       w1.channel AS first_channel,
       w2.occurred_at AS second_event_time,
       w2.channel AS second_channel
FROM web_events w1
LEFT JOIN web_events w2
ON w1.account_id = w2.account_id
AND w2.occurred_at > w1.occurred_at
AND w2.occurred_at <= w1.occurred_at + INTERVAL '1 day'
AND w2.id <> w1.id
ORDER BY w1.account_id, w1.occurred_at;


/*QUESTION:
Build a unified customer activity dataset by combining purchase activity and website interaction activity.
Return a table that includes customer purchases from the orders table and customer website interactions from the web_events table.
The result should contain the account_id, activity_time, activity_type, and activity_value to create a single chronological
activity log for customer behavior analysis.

REWRITE:
1) Final Output: Multiple rows - account_id, activity_time, activity_type, activity_value.
2) Group/Scope: No grouping required. The goal is to append activity records from two different sources.
3) Selection Logic: Extract purchase activity from the orders table.
                    Extract interaction activity from the web_events table.
4) Final Calculation: Use UNION ALL to combine both datasets into one unified activity log.

LOGIC:
Customer behavior is recorded in multiple tables. The orders table captures purchase transactions,
while the web_events table captures online transactions such as website visits and marketing channel engagement.
To analyze overall engagement, analysts often need a single activity timeline that combines these different sources.
1. Extract purchase records from the orders table and label them as order activity.
2. Extract interaction records from the web_events table and label them using the marketing channel.
3. Use UNION ALL to vertically append both datasets into one unified activity dataset.*/

SELECT account_id,
       occurred_at AS activity_time,
       'order' AS activity_type,
       total_amt_usd AS activity_value
FROM orders

UNION ALL

SELECT account_id,
       occurred_at AS activity_time,
       channel AS activity_type,
       NULL AS activity_value
FROM web_events;


/*QUESTION:
Create a unified contact directory by combining account contacts and sales representatives into a single dataset.
Return a list of contacts including the contact_name and contact_role.
This allows the company to quickly view all business contacts regardless of whether they are customers or internal sales representatives.

REWRITE:
1) Final Output: Multiple rows - contact_name and contact_role.
2) Group/Scope: No grouping required. Combine contacts from two tables.
3) Selection Logic: Extract primary contacts from the accounts table.
                    Extract sales representatives from the sales_reps table.
4) Final Calculation: Use UNION to combine both datasets into one contact directory.

LOGIC:
Business communication often involves both external contacts (customer representatives) and internal contacts
(sales representatives). These contacts are stored in separate tables. To create a unified directory:
1. Extract primary_poc from the accounts table.
2. Extract sales representative names from the sales_reps table.
3. Use UNION to combine both lists while removing duplicates.
This unified contact list can support reporting, outreach, or CRM systems.*/

SELECT primary_poc AS contact_name,
       'account contact' AS contact_role
FROM accounts

UNION

SELECT name AS contact_name,
       'sales rep' AS contact_role
FROM sales_reps;


/*QUESTION:
Analyze customer engagement by determining how many website interactions each account has generated.
Return the account_id, account_name, and total_web_events for each account.
Because the web_events table can contain a large number of records, structure the query efficiently,
so the join operates on a reduced dataset.

REWRITE:
1) Final Output: Multiple rows - account_id, account_name, total_web_events.
2) Group/Scope: One row per account.
3) Selection Logic: Aggregate the web_events table to count the number of events per account.
                    Join the aggregated result with the accounts table.
4) Final Calculation: Use COUNT(*) to calculate the total number of web events for each account.

LOGIC:
The web_events table can contain a large number of rows because it records every customer interaction on the website.
Joining the full web_events table with accounts first would require the database to process many rows during the join.
To improve efficiency:
1. Aggregate the web_events table first to count the number of events per account.
2. This produces a smaller dataset with one row per account.
3. Join this smaller dataset with the accounts table.*/

SELECT a.id AS account_id,
       a.name AS account_name,
       w.event_count AS total_web_events
FROM accounts a
JOIN
       (SELECT account_id,
              COUNT(*) AS event_count
       FROM web_events
       GROUP BY account_id) w
ON a.id = w.account_id;


/*QUESTION:
Evaluate account performance by calculating the total revenue generated by each account and comparing it to the overall average revenue per account.
Return the account_id, account_name, and total_revenue, and avg_revenue_per_account.
Order the results from the highest to lowest total revenue.

REWRITE:
1) Final Output: Multiple rows - account_id, account_name, total_revenue, avg_revenue_per_account.
2) Group/Scope: One row per account showing the revenue generated by that account.
3) Data Needed: Revenue data from the orders table.
                Account details from the accounts table.
4) Final Result: Total revenue generated by each account.
                 Comparison against the average revenue generated across all accounts.

LOGIC:
Revenue values are stored in the orders table, while account information is stored in the accounts table.
To evaluate account performance:
1. Aggregate the orders table to calculate total revenue generated by each account.
2. Calculate the average revenue per account across the dataset.
3. Join the aggregated revenue results with the accounts table to retrieve account names.
4. Include the overall average revenue value so that each account’s revenue can be compared to the average.*/

SELECT a.id AS account_id,
       a.name AS account_name,
       revenue.total_revenue,
       avg_rev.avg_revenue
FROM accounts a
JOIN
       (SELECT account_id,
              SUM(total_amt_usd) AS total_revenue
       FROM orders
       GROUP BY account_id
       ) revenue
ON a.id = revenue.account_id
JOIN
              (SELECT AVG(total_revenue) AS avg_revenue
              FROM
                     (SELECT account_id,
                            SUM(total_amt_usd) AS total_revenue
                     FROM orders
                     GROUP BY account_id
                     ) t
              ) avg_rev
ON avg_rev.avg_revenue = avg_rev.avg_revenue
ORDER BY revenue.total_revenue DESC;