# DataAnalytics-Assessment
COWRYWISE ASSESSMENT


### Question 1: Customers with Funded Savings and Investment Plans

### Approach:
- I began by identifying users who had deposited into their savings accounts (`confirmed_amount > 0`), which I grouped and aggregated by `owner_id` to get both `savings_count` and total `confirmed_amount` (later converted from kobo to naira).
- Then, I extracted users who had at least one investment plan (`is_a_fund = 1`) and counted them by `owner_id`.
- I used an inner join to ensure only users who had both funded savings and investment plans were selected.
- A `WHERE EXISTS` condition was added to make sure the customer has **at least one regular savings plan** (`is_regular_savings = 1`) in the `plans_plan` table.
- Results are sorted in descending order by the total deposit amount (converted to naira with two decimal places).


### Challenges:
- Ensuring correct filtering of customers to meet all three conditions: funded savings, funded investment, and at least one regular savings plan.
- Avoiding double-counting or misrepresenting deposit values due to joins or aggregation logic.
- Managing currency conversion correctly and keeping the query readable and efficient.




## Question 2: Transaction Frequency Analysis

### Approach:
1. Data Aggregation:
   - Count total transactions (`COUNT(*)`) per customer using the `savings_savingsaccount` table.
   - Determine how long each customer has been active by calculating the number of months between their earliest and latest transaction.

2. Average Transaction Calculation:
   - Divide total transactions by active months to get the average number of transactions per month.
   - Handle possible division by zero using `NULLIF`.

3. Categorization Logic:
   - Customers are grouped into:
     - High Frequency: ≥ 10 transactions/month
     - Medium Frequency: 3–9 transactions/month
     - Low Frequency: < 3 transactions/month

4. Result Aggregation:
   - Group results by frequency category.
   - Count customers in each category.
   - Compute the average monthly transactions per category for insight.


### Challenges:
- Active Month Calculation: Ensured accuracy by calculating both year and month differences and adding 1 to include the start month.
- Division by Zero: Used `NULLIF(active_months, 0)` to avoid runtime errors.
- Ordering Categories: Used a `CASE` statement in `ORDER BY` to control the category display order without relying on MySQL-specific functions like `FIELD()` for portability and clarity.




### Question 3: Account Inactivity Alert

### Approach:
- Defined active accounts as:
  - `is_regular_savings = 1` for Savings plans
  - `is_a_fund = 1` for Investment plans
- Used a `LEFT JOIN` between `plans_plan` and `savings_savingsaccount` to include:
  - Plans with no transactions at all (to catch those truly inactive)
- Applied `MAX(transaction_date)` to find the most recent inflow
- Used `DATEDIFF(CURRENT_DATE, last_transaction_date)` to calculate days since the last inflow
- Used `HAVING` to filter for:
  - Plans that have **never** received a transaction
  - Plans whose last inflow was **more than 365 days** ago


#### Challenges:
- No transactions scenario: Ensuring that plans with no transactions still appear in the result. This was handled with a `LEFT JOIN` and `HAVING last_transaction_date IS NULL`.
- Avoiding false positives: Filtering out inactive plans from the base table before aggregation ensured correct results.




### Q4: Customer Lifetime Value (CLV) Estimation

### Approach:
- I joined the `users_customuser` and `savings_savingsaccount` tables on the `owner_id` foreign key.
- Calculated each customer's tenure in months using `DATE_PART('month', AGE(...))`.
- Aggregated total confirmed savings transactions and converted the amount from **kobo to naira**.
- Applied the given CLV formula:
  \[
  CLV = \left(\frac{{\text{{total transactions}}}}{{\text{{tenure months}}}}\right) \times 12 \times (0.001 \times \text{{average transaction value}})
  \]


###Challenges:
- I had to prevent division by zero in cases where a user’s tenure was 0 months. I handled this using `NULLIF(...)` in the denominator.
- Ensuring correct average transaction value in naira required precise conversion from kobo and accurate grouping.
