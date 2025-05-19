-- Question 3: Account Inactivity Alert
-- Goal: Identify all active accounts (Savings or Investment) with no inflow transactions in the last 365 days.

SELECT 
    p.id AS plan_id,
    p.owner_id,
    CASE 
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
        ELSE 'Other'
    END AS type,
    MAX(s.transaction_date) AS last_transaction_date,
    DATEDIFF(CURRENT_DATE, MAX(s.transaction_date)) AS inactivity_days
FROM plans_plan p

-- LEFT JOIN to include plans with no transactions at all
LEFT JOIN savings_savingsaccount s
    ON s.plan_id = p.id

-- Filter to only active plans (Savings or Investment)
WHERE 
    p.is_regular_savings = 1 OR p.is_a_fund = 1

GROUP BY 
    p.id, p.owner_id, type

-- Only return plans with no inflows or last inflow over 365 days ago
HAVING 
    last_transaction_date IS NULL 
    OR DATEDIFF(CURRENT_DATE, last_transaction_date) > 365;
