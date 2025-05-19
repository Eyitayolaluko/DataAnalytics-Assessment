-- Assessment Q3: Account Inactivity Alert
-- Objective: Identify active savings or investment plans with no deposit activity in the past 365 days.

USE adashi_staging;

SELECT 
    p.id AS plan_id,                             -- Plan identifier
    p.owner_id,                                  -- Customer owning the plan
    CASE                                          -- Determine plan type
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
        ELSE 'Unknown'
    END AS type,
    
    MAX(s.transaction_date) AS last_transaction_date, -- Most recent deposit date
    DATEDIFF(CURDATE(), MAX(s.transaction_date)) AS inactivity_days -- Days since last deposit
FROM plans_plan p
LEFT JOIN savings_savingsaccount s ON s.plan_id = p.id
WHERE p.is_regular_savings = 1 OR p.is_a_fund = 1
GROUP BY p.id, p.owner_id, type
HAVING 
    last_transaction_date IS NULL OR inactivity_days > 365
ORDER BY inactivity_days DESC;
