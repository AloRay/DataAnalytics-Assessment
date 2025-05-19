-- Question 1: Transaction Frequency Analysis
-- This query computes the average number of deposit transactions per month per customer, classifies them into frequency tiers, and aggregates results by category.

WITH transaction_data AS (
    SELECT 
        sa.owner_id,
        COUNT(*) AS total_transactions,
        -- Calculate active months: difference between first and last transaction + 1
        DATE_PART('year', AGE(MAX(sa.created_at), MIN(sa.created_at))) * 12 +
        DATE_PART('month', AGE(MAX(sa.created_at), MIN(sa.created_at))) + 1 AS active_months
    FROM 
        savings_savingsaccount sa
    GROUP BY 
        sa.owner_id
),
avg_tx_per_month AS (
    SELECT 
        owner_id,
        total_transactions,
        active_months,
        ROUND(total_transactions::NUMERIC / NULLIF(active_months, 0), 2) AS avg_tx_per_month
    FROM 
        transaction_data
),
categorized_customers AS (
    SELECT 
        CASE 
            WHEN avg_tx_per_month >= 10 THEN 'High Frequency'
            WHEN avg_tx_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        avg_tx_per_month
    FROM 
        avg_tx_per_month
)
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_tx_per_month), 1) AS avg_transactions_per_month
FROM 
    categorized_customers
GROUP BY 
    frequency_category
ORDER BY 
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        WHEN 'Low Frequency' THEN 3
    END;
