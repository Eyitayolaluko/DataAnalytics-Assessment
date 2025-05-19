-- Assessment Q2: Transaction Frequency Analysis
-- Objective: Categorize customers based on their average transaction frequency per month.
-- Categories: High (≥10), Medium (3–9), Low (≤2)

USE adashi_staging;

-- Step 1: Calculate average monthly transactions per customer
WITH customer_transactions AS (
    SELECT 
        u.id AS customer_id,
        u.name,
        COUNT(sa.id) AS total_transactions,
        GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE()), 1) AS tenure_months,
        ROUND(COUNT(sa.id) / GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE()), 1), 1) AS avg_tx_per_month
    FROM users_customuser u
    JOIN plans_plan p ON p.owner_id = u.id
    JOIN savings_savingsaccount sa ON sa.plan_id = p.id
    GROUP BY u.id, u.name, u.date_joined
),

-- Step 2: Categorize customers by transaction frequency
categorized_customers AS (
    SELECT 
        customer_id,
        name,
        avg_tx_per_month,
        CASE
            WHEN avg_tx_per_month >= 10 THEN 'High Frequency'
            WHEN avg_tx_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM customer_transactions
)

-- Final Output: Group by frequency category
SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_tx_per_month), 1) AS avg_transactions_per_month
FROM categorized_customers
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
