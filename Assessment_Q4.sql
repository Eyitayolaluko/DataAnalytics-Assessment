-- Assessment Q4: Customer Lifetime Value (CLV) Estimation
-- Objective: Estimate each customer’s CLV based on their deposit volume and account tenure.

USE adashi_staging;

SELECT 
    u.id AS customer_id,
    u.name,
    
    -- Calculate tenure in months since signup
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,

    -- Sum of all confirmed deposits (converted from kobo to naira)
    ROUND(SUM(s.confirmed_amount) / 100, 2) AS total_transactions,

    -- CLV formula: (total / tenure) * 12 * 0.001
    ROUND( 
        (SUM(s.confirmed_amount) / 100) * 
        (12 / NULLIF(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 0)) * 
        0.001,
        2
    ) AS estimated_clv

FROM users_customuser u
JOIN savings_savingsaccount s ON u.id = s.owner_id
GROUP BY u.id, u.name, u.date_joined
ORDER BY estimated_clv DESC;
