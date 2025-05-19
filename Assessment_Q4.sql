-- Assessment Q4: Customer Lifetime Value (CLV) Estimation
-- Objective: Estimate each customer’s CLV based on their transaction volume and tenure.

USE adashi_staging;

-- Step-by-step:
-- 1. Compute total transactions and total confirmed amount (in Naira)
-- 2. Compute average transaction value
-- 3. Derive avg profit per transaction (0.1%)
-- 4. Use CLV formula: (total_tx / tenure) * 12 * avg_profit_per_tx

WITH transaction_summary AS (
    SELECT 
        u.id AS customer_id,
        u.name,
        TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
        COUNT(s.id) AS total_transactions,
        ROUND(SUM(s.confirmed_amount) / 100, 2) AS total_transaction_value_naira,  -- Convert from kobo
        ROUND(AVG(s.confirmed_amount) / 100, 2) AS avg_transaction_value_naira     -- Convert from kobo
    FROM users_customuser u
    JOIN savings_savingsaccount s ON u.id = s.owner_id
    GROUP BY u.id, u.name, u.date_joined
)

SELECT 
    customer_id,
    name,
    GREATEST(tenure_months, 1) AS tenure_months,  -- Prevent divide-by-zero
    total_transactions,
    
    -- CLV = (total_tx / tenure) * 12 * (0.001 * avg_transaction_value)
    ROUND( 
        (total_transactions / GREATEST(tenure_months, 1)) * 12 * (0.001 * avg_transaction_value_naira),
        2
    ) AS estimated_clv

FROM transaction_summary
ORDER BY estimated_clv DESC;
