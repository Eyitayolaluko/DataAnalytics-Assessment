# DataAnalytics-Assessment
Data Analyst Assessment


##  Database Overview

**Database Name:** `adashi_staging`  


###  Key Tables Used

| Table Name                | Description |
|--------------------------|-------------|
| `users_customuser`       | Contains customer demographic and registration data. |
| `plans_plan`             | Details of user plans — including both savings (`is_regular_savings`) and investment (`is_a_fund`) plans. |
| `savings_savingsaccount` | Records of confirmed deposit transactions linked to plans. |
| `withdrawals_withdrawal` | Records of withdrawal transactions *(not used in this assessment)*. |

---

##  Assessment Objectives & Solutions

Each SQL solution is modularized using Common Table Expressions (CTEs), meaningful aliases, and clear formatting. All monetary values stored in **kobo** are converted to **naira** by dividing by 100.

---

##  Assessment Q1: High-Value Customers with Multiple Products


##  Objective

Identify customers who have at least one funded savings plan and at least one funded investment plan, as part of a cross-selling opportunity. Additionally, calculate the total value of deposits made by each customer (converted from kobo to naira), and sort the results in descending order of total deposits.


##  Approach

Filter for Funded Plans
I guessed that a plan is considered funded if it has at least one associated deposit in the savings_savingsaccount table.
For savings plans, I filtered plans_plan where is_regular_savings = 1 and ensured it was linked to at least one record in savings_savingsaccount.
For investment plans, I used is_a_fund = 1 and applied the same logic.

Count Product Types
I used two Common Table Expressions (CTEs) to count how many distinct funded savings and distinct funded investment plans each customer owns.

Aggregate Deposit Values
Another CTE computed the total confirmed deposits (confirmed_amount) per customer by joining plans_plan and savings_savingsaccount. Since the data is in kobo, I converted it to naira by dividing by 100 and rounding to 2 decimal places.

Final Output
Only customers who have both at least one funded savings and one funded investment plan were included (via inner joins).
The result displays the customer's ID, name, counts of each product type, and total deposit value in naira.
Sorted by total_deposits in descending order to surface the highest value customers first.



##  Query Techniques Used

Common Table Expressions (CTEs) for modular query structure
JOIN operations across multiple tables
Filtering based on specific column values (is_regular_savings, is_a_fund)
Aggregation with COUNT(DISTINCT ...) and SUM(...)
IFNULL() to handle customers with no recorded deposits
ROUND() and arithmetic conversion for currency formatting



##  Challenges

Clarifying the definition of a “funded” plan: The instructions did not explicitly define whether a plan needed just one transaction or a non-zero confirmed_amount to be considered funded.
I addressed this by assuming that any associated deposit record qualifies a plan as funded.

 


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


##  Assessment Q2: Transaction Frequency Analysis


##  Objective

Segment customers based on their average number of transactions per month. This classification enables the business to identify frequent users for targeted marketing or customer engagement.


##  Approach

Calculate average transactions per month
First, I calculated the total number of savings transactions made by each customer using a COUNT on savings_savingsaccount.
Then I determined each customer's account tenure in months using TIMESTAMPDIFF(MONTH, date_joined, CURRENT_DATE()).
To avoid division-by-zero errors for recent signups, I used GREATEST(..., 1) to enforce a minimum tenure of 1 month.
The average monthly transaction rate is calculated by dividing total transactions by tenure.

Categorize customers by frequency
I classified each customer into one of three buckets based on their average monthly transaction rate:
High Frequency: 10 or more transactions/month
Medium Frequency: 3 to 9 transactions/month
Low Frequency: 2 or fewer transactions/month

Aggregate results
The final output groups customers by their frequency category.
For each group, I showed:
Total number of customers in that category
Average transaction frequency (rounded to 1 decimal)

Ordering and readability
Results are sorted using FIELD(...) to ensure the categories appear in a logical order: High → Medium → Low.


##  Query Techniques Used

WITH Common Table Expressions (CTEs) for modular organization
TIMESTAMPDIFF() to compute account age
ROUND() and GREATEST() for precision and safety
CASE for categorical logic
ORDER BY FIELD() for custom sorting




------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 
##  Assessment Q3: Account Inactivity Alert


##  Objective:

Identify active savings or investment plans that have had no deposit transactions in the last 365 days. This allows the business to flag dormant accounts for further action.


##  Approach:

To solve this, I focused on plans classified as either savings or investments. 

I joined the plans_plan table with the savings_savingsaccount table to access transaction data. Using aggregation, I found the most recent deposit date for each plan. 

For plans without any deposits, the MAX(transaction_date) would return NULL. 

I then calculated the number of days since the last deposit by subtracting this date from the current date. 

Finally, I filtered for plans that have been inactive for more than 365 days or have never had deposits.


##  Query Techniques Used:

LEFT JOIN: Ensured all active plans are included, even if they have no transactions.
Aggregate function (MAX): Used to find the latest transaction date per plan.
Conditional filtering (HAVING clause): Filtered aggregated results to find plans with inactivity exceeding the threshold or no deposits.
CASE statement: Created a readable plan type label ("Savings" or "Investment") based on plan attributes.
Date functions (DATEDIFF, CURDATE): Calculated inactivity period.
Grouping (GROUP BY): Grouped data by plan to aggregate transactions correctly.


##  Challenges:

Ensuring plans with no deposits were included required using a LEFT JOIN and handling NULL values correctly in the aggregation and filtering steps.
Accurately differentiating between savings and investment plans was important for clarity and was handled with a CASE statement.
Handling date arithmetic carefully to avoid errors, especially when the last transaction date was NULL.
 



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   

##  Assessment Q4: Customer Lifetime Value (CLV) Estimation


##  Objective

Estimate the Customer Lifetime Value (CLV) for each customer using their total transaction value and the duration of their account activity. The model is simplified and based on the formula:
CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction
Assume avg_profit_per_transaction = 0.001 (i.e., 0.1%)
Tenure is calculated in months since the customer's signup (date_joined)
Transaction values are in kobo, and need to be converted to naira (divide by 100)


##  Approach

Calculate Tenure
Used TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) to compute the number of months between the account signup date and the current date.
To prevent division-by-zero, NULLIF(..., 0) was applied in the final formula.

Total Transactions
Aggregated the total deposit amount (confirmed_amount) from savings_savingsaccount, grouped by customer.
Converted from kobo to naira using / 100 and rounded to 2 decimal places.

Estimate CLV
Applied the simplified CLV formula directly in the query:
CLV = (total_in_naira / tenure_months) * 12 * 0.001
Rounded the result to 2 decimal places.

Final Output Displays:
customer_id
name
tenure_months
total_transactions (in naira)
estimated_clv
Results are sorted by estimated_clv in descending order, surfacing the highest-value customers.


##  Query Techniques Used

Date calculations using TIMESTAMPDIFF
Aggregate functions (SUM, ROUND)
Null-safe arithmetic using NULLIF(...) to prevent division-by-zero
Table joins betIen users_customuser and savings_savingsaccount
Conversion of currency from kobo to naira


##  Challenges

Ensuring that the tenure_months did not result in a division by zero when the account was created very recently (e.g., current month).
This was resolved by using NULLIF(tenure_months, 0) within the formula.

Accurately mapping deposit transactions to customers, since deposits reside in the savings_savingsaccount table, but customer info resides in users_customuser.
This was handled with a JOIN based on the owner_id.

------------------------------------------------------------------------------------------------------------------------------------------------

##  Execution Environment

- **SQL Engine:** MySQL 8.0  
- **Development Tool:** MySQL Workbench  
- **Database Used:** `adashi_staging`  
- **Tested On:** Sample dataset from assessment
