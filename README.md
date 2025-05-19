# DataAnalytics-Assessment
COWRYWISE ASSESSMENT


### Question 1: Customers with Funded Savings and Investment Plans

### Approach:
- I began by identifying users who had deposited into their savings accounts (`confirmed_amount > 0`), which I grouped and aggregated by `owner_id` to get both `savings_count` and total `confirmed_amount` (later converted from kobo to naira).
- Then, I extracted users who had at least one investment plan (`is_a_fund = 1`) and counted them by `owner_id`.
- I used an inner join so that only users who had both funded savings and investment plans were selected.
- A `WHERE EXISTS` condition was added to make sure the customer has **at least one regular savings plan** (`is_regular_savings = 1`) in the `plans_plan` table.
- Results are sorted in descending order by the total deposit amount (converted to naira with two decimal places).


### Challenges:
- I had to be careful to correctly filter customers to meet all three conditions: funded savings, funded investment, and at least one regular savings plan.
- I was conscious to avoid double-counting or misrepresenting deposit values due to joins or aggregation logic.
- I almost submitted then I remembered to correctly convert currency and keep the query as readable and as efficient as possible.




## Question 2: Transaction Frequency Analysis

### Approach:
- For this analysis, I started by aggregating the transaction data. I pulled all the records from the savings_savingsaccount table and counted the total number of transactions per customer. To understand how long each customer has been active, I looked at the difference between their first and last transaction dates and converted that into months and that gave me their activity period.

- Next, I calculated the average number of transactions per month for each customer. I was careful to handle any potential division by zero by using NULLIF just in case someone had only one transaction or the same date for both first and last transactions.

- Once I had the average, I categorized the customers into three frequency bands:
i) High Frequency for those averaging 10 or more transactions per month
ii) Medium Frequency for those between 3 and 9
iii) Low Frequency for those with less than 3 per month

- Finally, I grouped everything by frequency category, counted how many customers fell into each group, and also calculated the average transactions per month per category for deeper insights. This way, the finance team can clearly see the breakdown of user engagement across the platform.


### Challenges:
- For the aActive month calculation, I guaranteed accuracy by calculating both year and month differences and adding 1 to include the start month.
- To avoid runtime errors, I used `NULLIF(active_months, 0)`
- In ordering categories, I used a `CASE` statement in `ORDER BY` to control the category display order without relying on MySQL-specific functions like `FIELD()` for portability and clarity.




### Question 3: Account Inactivity Alert

### Approach:
- Defined active accounts as:
  - `is_regular_savings = 1` for Savings plans
  - `is_a_fund = 1` for Investment plans
- I used a `LEFT JOIN` between `plans_plan` and `savings_savingsaccount` to include:
  - Plans with no transactions at all (to catch those truly inactive)
- Applied `MAX(transaction_date)` to find the most recent inflow
- Used `DATEDIFF(CURRENT_DATE, last_transaction_date)` to calculate days since the last inflow
- Used `HAVING` to filter for:
  - Plans that have **never** received a transaction
  - Plans whose last inflow was **more than 365 days** ago


#### Challenges:
- I initially used and inner join but realized I needed only those with transactions so I opted for a "LEFT JOIN' and `HAVING last_transaction_date IS NULL`.
- I filtered out inactive plans from the base table before aggregation to avoid false positives and to produce correct results.




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
- Correct average transaction value in naira required precise conversion from kobo and accurate grouping.
