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
