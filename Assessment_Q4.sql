-- Assessment_Q4.sql
-- Task: Customer Lifetime Value (CLV) Estimation

SELECT
    u.id AS customer_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    DATE_PART('month', AGE(CURRENT_DATE, u.date_joined)) AS tenure_months,
    COUNT(s.id) AS total_transactions,
    
    -- CLV formula:
    -- CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction
    -- Where avg_profit_per_transaction = 0.001 * average transaction value (converted from kobo to naira)
    ROUND(
        (
            (COUNT(s.id) * 0.001 * SUM(s.confirmed_amount) / COUNT(s.id) / 100)
            / NULLIF(DATE_PART('month', AGE(CURRENT_DATE, u.date_joined)), 0)
        ) * 12,
        2
    ) AS estimated_clv

FROM
    users_customuser u
JOIN
    savings_savingsaccount s ON u.id = s.owner_id

GROUP BY
    u.id, u.first_name, u.last_name, u.date_joined

ORDER BY
    estimated_clv DESC;
