/*QUESTION:
In the accounts table, how many companies use each website extension?

REWRITE:
1) Final Output: Multiple rows - website_extension and count.
2) Group/Scope: Group by website extension.
3) Seleciton Logic: Extract the last three characters from the website column.
4) Final Calculation: COUNT(*) for each extracted extension.

LOGIC:
First extract the last three characters from each website. Then group by those extracted values.
Finally count how many times each extension appears.*/

SELECT RIGHT(website, 3) AS domain,
       COUNT(*) AS num_companies
FROM accounts
GROUP BY RIGHT(website, 3)
ORDER BY num_companies DESC;


/*QUESTION:
From the accounts table, pull the first letter of each company name to see the distribution of each company names,
that begin with each letter or number.

REWRITE:
1) Final Output: Multiple rows - first_char and count.
2) Group/Scope: Group by first letter.
3) Selection Logic: Extract the first character from the name column.
4) Final Calculation: COUNT(*) for each extracted letter.

LOGIC:
First extract the first character from each name. Then group by those extracted values.
Finally count how many times each character appears*/

SELECT LEFT(UPPER(name), 1) AS first_char,
       COUNT(*) AS num_companies
FROM accounts
GROUP BY LEFT(UPPER(name), 1)
ORDER BY num_companies DESC;


/*QUESTION:
Use the accounts table and a CASE statement to create two groups:
one group of company names that start with a number.
And a second group of those company names that start with a letter. What proportion of company names start with a letter?

REWRITE:
1) Final Output: One row - showing proportion (percentage) of company names that starts with a letter.
2) Group/Scope: No grouping by rows. We classify rows using CASE.
3) Selection Logic: Use CASE to label each company as:
                    "number" if name starts with digit. "letter" otherwise.
4) Final Calculation: Count how many are letters/total companies.

LOGIC:
Extract first character of each company name. Use CASE to mark as number-start or letter-start.
Count letters and total rows. Divide letter count by total count.*/

SELECT SUM
              (CASE WHEN LEFT(name, 1) NOT BETWEEN '0' AND '9'
              THEN 1
              ELSE 0
              END) * 1.0 /
       COUNT(*) AS proportion_starting_with_letter
FROM accounts;


/*QUESTION:
Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.

REWRITE:
1) Final Output: Multiple rows - first_name and last_name.
2) Group/Scope: No grouping required.
3) Selection Logic: Use STRPOS to find the position of the space between first and last name.
                    Extract characters before the space for first_name.
                    Extract characters after the space for last_name.
4) Final Calculation: Use LEFT and RIGHT (or SUBSTR) with STRPOS to separate the name.

LOGIC:
Find the position of the space in primary_poc.
Extract everything before the space as first_name.
Extract everything after the space as last_name.*/

SELECT 
    SUBSTR(primary_poc, 1, STRPOS(primary_poc, ' ') - 1) AS first_name,
    SUBSTR(primary_poc, STRPOS(primary_poc, ' ') + 1) AS last_name
FROM accounts;


/*QUESTION:
From the accounts table, extract the domain name from the website column (removing 'www.').

REWRITE:
1) Final Output: Multiple rows - domain_name.
2) Group/Scope: No grouping required.
3) Selection Logic: Find the position of 'www.' and remove it using SUBSTR.
4) Final Calculation: Use STRPOS and SUBSTR to extract domain.

LOGIC:
Locate 'www.' in the website column
Start extracting characters after 'www.'
Return remaining portion as domain name.*/

SELECT
       SUBSTR(website, STRPOS(website, 'www.') + 4) AS domain_name
FROM accounts;


/*QUESTION:
Each company in the accounts table wants to create an email address for each primary_poc.
The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.
The format should be: first_name.last_name@companyname.com.

REWRITE:
1) Final Output: Multiple rows - email_address.
2) Group/Scope: No grouping required.
3) Selection Logic: Extract first name from primary_poc using SUBSTR and STRPOS.
                    Extract last name from primary_poc using SUBSTR and STRPOS.
                    Keep the company name as it is.
4) Final Calculation: Concatenate first_name, '.', last_name, '@', company_name, and '.com'.
                      Convert the final result to lower case.

LOGIC:
First create a CTE to extract first_name and last_name from primary_poc.
Then build the email address by concatenating:
first_name + '.' + last_name + '@' + company_name + '.com'.
Convert the final string to lower case.*/

WITH name_parts AS (SELECT primary_poc,
                           name AS company_name,
                           SUBSTR(primary_poc, 1, STRPOS(primary_poc, ' ')-1) AS first_name,
                           SUBSTR(primary_poc, STRPOS(primary_poc, ' ')+1) AS last_name
                    FROM accounts)

SELECT LOWER(first_name || '.' || last_name || '@' || company_name || '.com') AS email_address
FROM name_parts;


/*QUESTION:
Modify the previous email creation query so that all spaces are removed from the company name.
The format should still be: first_name.last_name@companyname.com.

REWRITE:
1) Final Output: Multiple rows - email_address.
2) Group/Scope: No grouping required.
3) Selection Logic: Extract first name from primary_poc using SUBSTR and STRPOS.
                    Extract last name from primary_poc using SUBSTR and STRPOS.
                    Remove all spaces from company name using REPLACE.
4) Final Calculation: Concatenate first_name, '.', last_name, '@', cleaned_company_name, and '.com'.
                      Convert the final result to lower case.

LOGIC:
First create a CTE to extract first_name and last_name from primary_poc.
Use REPLACE to remove spaces from the company name.
Then build the email address in the format:
first_name.last_name@companyname.com
Convert the final string to lowercase.*/

WITH name_parts AS (SELECT SUBSTR(primary_poc, 1, STRPOS(primary_poc, ' ') -1) AS first_name,
                   SUBSTR(primary_poc, STRPOS(primary_poc, ' ') +1) AS last_name,
                   REPLACE(name, ' ', '') AS company_name_clean
            FROM accounts)

SELECT LOWER(first_name || '.' || last_name || '@' || company_name_clean || '.com') AS email_address
FROM name_parts;


/*QUESTION:
The date column in the sf_crime_data table is stored as TEXT 
in the format 'MM/DD/YYYY HH:MI:SS AM +0000'.
Convert this column into the proper SQL DATE format (YYYY-MM-DD)
using SUBSTR and CONCAT, and then CAST it to DATE.

REWRITE:
1) Final Output: Multiple rows - formatted_date.
2) Group/Scope: No grouping required.
3) Selection Logic:
   - Extract year using SUBSTR(date, 7, 4).
   - Extract month using SUBSTR(date, 1, 2).
   - Extract day using SUBSTR(date, 4, 2).
   - Rearrange into 'YYYY-MM-DD' format using CONCAT.
4) Final Calculation:
   CAST the rearranged string as DATE.

LOGIC:
The original date is stored as TEXT in MM/DD/YYYY format.
Extract year, month, and day separately.
Reorder them into YYYY-MM-DD format.
Then convert the string into an actual DATE using CAST.*/

SELECT CAST(
            CONCAT(
                   SUBSTR(incident_datetime, 7, 4), '-',
                   SUBSTR(incident_datetime, 1, 2), '-',
                   SUBSTR(incident_datetime, 4, 2)) AS DATE) AS formatted_date
FROM sf_crime_data;


/*QUESTION:
Extract the year from the incident_datetime column and convert it into INTEGER for analytical use.

REWRITE:
1) Final Output: Multiple rows - incident_year (integer).
2) Group/Scope: No grouping required.
3) Selection Logic: Extract characters 7-10 (YYYY portion) using SUBSTR.
4) Final Calculation: Use CAST to convert year into INTEGER.

LOGIC:
The incident_datetime column is stored as TEXT. Extract the year portion (YYYY) from the string and convert it to INTEGER using CAST,
so it can be used in numerical analysis and grouping.*/

SELECT CAST(SUBSTR(incident_datetime, 7, 4) AS INTEGER) AS incident_year
FROM sf_crime_data;