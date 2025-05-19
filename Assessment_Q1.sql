-- Assessment Q1: High-Value Customers with Multiple Products
-- Objective: Identify customers who have both a funded savings plan AND a funded investment plan.
-- For each qualifying customer, show the number of savings and investment plans and total deposits made.
-- Results are sorted by total deposits (in Naira) in descending order.

USE adashi_staging;

-- Step 1: Retrieve customers with funded savings plans
WITH savings AS (
    SELECT p.owner_id, COUNT(DISTINCT p.id) AS savings_count
    FROM plans_plan p
    JOIN savings_savingsaccount s ON s.plan_id = p.id
    WHERE p.is_regular_savings = 1
    GROUP BY p.owner_id
),

-- Step 2: Retrieve customers with funded investment plans
investment AS (
    SELECT p.owner_id, COUNT(DISTINCT p.id) AS investment_count
    FROM plans_plan p
    JOIN savings_savingsaccount s ON s.plan_id = p.id
    WHERE p.is_a_fund = 1
    GROUP BY p.owner_id
),

-- Step 3: Calculate total deposit amount per customer
deposits AS (
    SELECT p.owner_id, SUM(s.confirmed_amount) AS total_deposit
    FROM savings_savingsaccount s
    JOIN plans_plan p ON s.plan_id = p.id
    GROUP BY p.owner_id
)

-- Final Result: Join all components and format output
SELECT
    u.id AS owner_id,
    u.name,
    s.savings_count,
    i.investment_count,
    ROUND(IFNULL(d.total_deposit, 0) / 100, 2) AS total_deposits
FROM users_customuser u
JOIN savings s ON s.owner_id = u.id
JOIN investment i ON i.owner_id = u.id
LEFT JOIN deposits d ON d.owner_id = u.id
ORDER BY total_deposits DESC;
