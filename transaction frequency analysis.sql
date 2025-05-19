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