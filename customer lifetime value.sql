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
