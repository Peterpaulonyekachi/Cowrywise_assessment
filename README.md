# Cowrywise_assessment
##  High-Value Customers with Multiple Products
Goal of the Query
- The query retrieves a list of all users along with:
- Their email and full name
- Their total savings amount
- Their total investment amount
- Their combined total deposit (savings + investment)
- The results are sorted by total deposit in descending order, so the highest value customers appear first.
```sql
SELECT 
    u.id AS user_id,
    u.email,
   concat(u.first_name," ",u.last_name) as fullname,
    COALESCE(s.total_savings, 0) AS total_savings,
    COALESCE(p.total_investment, 0) AS total_investment,
    COALESCE(s.total_savings, 0) + COALESCE(p.total_investment, 0) AS total_deposit
FROM users_customuser u
-- create a left join to get the sum of successful savings per user from the savings_savingaccount
-- Filter to get successful transactions 
-- group by owner_id
-- then return a single row per user with their total savings

LEFT JOIN (
    SELECT owner_id, SUM(amount) AS total_savings
    FROM savings_savingsaccount
    WHERE transaction_status = 'success'  -- funded savings only
    GROUP BY owner_id
) s ON u.id = s.owner_id
-- join sum of invstments per user from the plans_plan table
-- filter investment plans as plan_type_id = 1
-- Group by owner_id to get each user's total investment
LEFT JOIN (
    SELECT owner_id, SUM(amount) AS total_investment
    FROM plans_plan
    WHERE plan_type_id = 1  -- investment plans only
    GROUP BY owner_id
) p ON u.id = p.owner_id
-- sort the final result by total_deposit, highest first
ORDER BY total_deposit DESC;
-- this query helps to identify top depositors,View customer engagement in savings vs. investment products and support marketing
```

## Transaction Frequency Analysis
Goal of the Query
- Segment users based on how frequently they make successful savings transactions per month:
    High Frequency: ≥ 10 transactions/month
    Medium Frequency: 3–9 transactions/month
    Low Frequency: ≤ 2 transactions/month
- The final result shows:
- Frequency category
- Number of users in each category
- Average transactions per month for each group

```sql
WITH user_monthly_transactions AS (
    SELECT
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m') AS txn_month,
        COUNT(*) AS monthly_txn_count
    FROM savings_savingsaccount
    WHERE transaction_status = 'success'
    GROUP BY owner_id, txn_month
),
-- the above query filters for successful transactions only,
-- groups user by the user_id and month by txn_month then counts how many successful transactions each user made per month
user_avg_txn_per_month AS (
    SELECT
        owner_id,
        AVG(monthly_txn_count) AS avg_txn_per_month
    FROM user_monthly_transactions
    GROUP BY owner_id
),
-- this query computes the average number of transactions per month. it helps for frequency classification
user_frequency_classification AS (
    SELECT
        u.owner_id,
        avg_txn_per_month,
        CASE
            WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txn_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM user_avg_txn_per_month u
)
-- classifies each user into one of the 3 frequency buckets based on their avg_txn_per_month
SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_txn_per_month), 1) AS avg_transactions_per_month
FROM user_frequency_classification
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
-- the final output groups each frequency category, counts how many users fal into each category, calculates the average for users in each group
-- then sorts results using field()
```

## Account Inactivity Alert
Goal of the Query
- Identify inactive accounts:
    Find all active savings and investment accounts that have had no successful transactions in the last 365 days (i.e., inactive for over a year).
- Distinguish account types:
    Separate the inactive accounts into two types:
- Savings accounts (from savings_savingsaccount)
- Investment plans (from plans_plan where plan_type_id = 1)
- Report last activity and inactivity duration:
- For each inactive account, report:
    The last transaction date or last activity date (transaction_date for savings, created_on for investments)
- How many days have passed since that last transaction (inactivity_days)
- Provide a summary view for operations:
- Enable the operations team to quickly flag accounts that have not had any money inflow for over a year so they can investigate, reach out, or take necessary actions like account review or follow-up.

```sql
-- Get current date
SET @today = CURDATE();

-- 1. Savings accounts with no transaction in last 365 days
SELECT 
    s.id AS plan_id,
    s.owner_id,
    'Savings' AS type,
    MAX(s.transaction_date) AS last_transaction_date,
    DATEDIFF(@today, MAX(s.transaction_date)) AS inactivity_days
FROM savings_savingsaccount s
WHERE s.transaction_status = 'success'  -- Filter only successful transactions
GROUP BY s.owner_id
HAVING MAX(s.transaction_date) < DATE_SUB(@today, INTERVAL 365 DAY)

UNION

-- 2. Investment plans with no transaction in last 365 days
SELECT 
    p.id AS plan_id,
    p.owner_id,
    'Investment' AS type,
    MAX(p.created_on) AS last_transaction_date,
    DATEDIFF(@today, MAX(p.created_on)) AS inactivity_days
FROM plans_plan p
WHERE p.plan_type_id = 1  -- Only investment
```

## Customer Lifetime Value
The Goal of the Query 
- To estimate the Customer Lifetime Value (CLV) for each customer based on their account tenure and transaction history, using the following approach:
- Calculate account tenure:
It computes how many months each customer has been active since they joined (tenure_months).
- Count total transactions:
It counts the total number of successful transactions the customer has made (total_transactions).
- Estimate CLV:
Using a simplified model, it estimates the CLV by:
- Calculating the average monthly transactions (total_transactions / tenure_months), scaling this to an annual basis (* 12), multiplying by the average profit per transaction (assumed as 0.1% of transaction amount, represented by amount * 0.001)
- This gives an estimated annual profit value per customer, rounded to 2 decimals.
- Order customers by CLV:
The result is sorted to show customers with the highest estimated lifetime value at the top.

```sql
SELECT 
    u.id AS customer_id,
    concat(u.first_name," ",u.last_name) as fullname,
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
    COUNT(s.id) AS total_transactions,
    ROUND(
        (COUNT(s.id) / NULLIF(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 0)) 
        * 12 
        * AVG(s.amount * 0.001),
        2
    ) AS estimated_clv
FROM users_customuser u
JOIN savings_savingsaccount s ON u.id = s.owner_id
WHERE s.transaction_status = 'success'
GROUP BY u.id, u.name, u.date_joined
ORDER BY estimated_clv DESC;
```



