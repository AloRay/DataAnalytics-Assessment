-- Question 1: Customers with both funded savings and investment plans
-- Output: owner_id, name, savings_count, investment_count, total_deposits (in Naira)

SELECT 
    u.id AS owner_id,
    u.name,
    s.savings_count,
    p.investment_count,
    ROUND(s.total_deposits / 100.0, 2) AS total_deposits  -- Kobo to Naira
FROM 
    users_customuser u
JOIN (
    -- Subquery for savings plan: count and sum of confirmed_amount > 0
    SELECT 
        owner_id,
        COUNT(*) AS savings_count,
        SUM(confirmed_amount) AS total_deposits
    FROM 
        savings_savingsaccount
    WHERE 
        confirmed_amount > 0
    GROUP BY 
        owner_id
) s ON u.id = s.owner_id
JOIN (
    -- Subquery for investment plans with is_a_fund = 1
    SELECT 
        owner_id,
        COUNT(*) AS investment_count
    FROM 
        plans_plan
    WHERE 
        is_a_fund = 1
    GROUP BY 
        owner_id
) p ON u.id = p.owner_id
-- Ensure the user also owns at least one regular savings plan
WHERE EXISTS (
    SELECT 1 
    FROM plans_plan pp
    WHERE pp.owner_id = u.id AND pp.is_regular_savings = 1
)
ORDER BY 
    total_deposits DESC;
