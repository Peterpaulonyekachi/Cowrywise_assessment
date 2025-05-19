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
