# DataAnalytics-Assessment
COWRYWISE ASSESSMENT


## Question 1: Customers with Funded Savings and Investment Plans

### Approach:
- I began by identifying users who had deposited into their savings accounts (`confirmed_amount > 0`), which I grouped and aggregated by `owner_id` to get both `savings_count` and total `confirmed_amount` (later converted from kobo to naira).
- Then, I extracted users who had at least one investment plan (`is_a_fund = 1`) and counted them by `owner_id`.
- I used an inner join so that only users who had both funded savings and investment plans were selected.
- A `WHERE EXISTS` condition was added to make sure the customer has **at least one regular savings plan** (`is_regular_savings = 1`) in the `plans_plan` table.
- Results are sorted in descending order by the total deposit amount (converted to naira with two decimal places).


### Challenges:
- This question gave me a bit of a tough time at first. I had to make sure I was picking only the customers who truly met all three conditions: they needed to have at least one funded savings plan, one funded investment plan, and at least one regular savings plan. Missing even one of these would have changed the results completely, so I had to pay close attention to how I filtered the data.
- Another thing I had to be careful with was the way I joined the tables and did my aggregations. It’s very easy to mistakenly double-count deposits or misrepresent the total if the joins aren’t done properly. I had to go over the logic more than once to be sure everything was counting correctly.
- Then shortly before submitting, I remembered to convert all the amount values from kobo to naira. That would have been a big miss. I also took some extra time to clean up the query so that it was readable, clear, and efficient.




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
- For the active month calculation, I wanted to be sure I was getting it right, so I calculated both the year and month differences, then added 1 to capture the starting month. That way, even if the first and last transactions were in the same month, it wouldn’t show as zero.
- I also made sure to avoid any runtime errors by wrapping the division in NULLIF(active_months, 0). It’s a small thing, but easy to forget when you’re deep in the logic.
- When it came to ordering the frequency categories (High, Medium, and Low) I used a CASE statement in the ORDER BY clause. I avoided MySQL-specific functions like FIELD() just to keep the query more portable and easier for anyone else to understand, no matter the SQL flavor they’re used to.
- Then for the high-value customers question, I had to really pay attention to the filtering. It wasn’t just about who had deposits, I had to check for customers who had both funded savings and investment plans, plus at least one regular savings plan. Missing one of those would’ve made the result invalid.
- Another thing I had to be extra careful with was avoiding double-counting when joining and aggregating data. It’s easy to mess up totals when joins start duplicating rows.
- At the last minute I remembered that all the amounts were in kobo. So I went back, made sure I converted everything to naira, and also cleaned up the query for readability and performance.




## Question 3: Account Inactivity Alert

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
- I initially used and inner join but realized I needed only those with transactions so I switched to a 'LEFT JOIN' instead and used a 'HAVING last_transaction_date IS NULL' to isolate the truly inactive ones.
- Another thing I had to be careful about was filtering out inactive plans from the base table before running any aggregation. If I didn’t do that early, I would’ve ended up including plans that shouldn’t count at all, which would have messed up the results. Making that adjustment upfront saved me from a lot of back and forth.




## Q4: Customer Lifetime Value (CLV) Estimation

### Approach:
- I joined the `users_customuser` and `savings_savingsaccount` tables on the `owner_id` foreign key.
- Calculated each customer's tenure in months using `DATE_PART('month', AGE(...))`.
- Aggregated total confirmed savings transactions and converted the amount from **kobo to naira**.
- Applied the given CLV formula:
  \[
  CLV = \left(\frac{{\text{{total transactions}}}}{{\text{{tenure months}}}}\right) \times 12 \times (0.001 \times \text{{average transaction value}})
  \]


###Challenges:
- One challenge I ran into was making sure I avoided division by zero, especially for customers whose account tenure came out as 0 months. That would’ve caused errors in the query, so I used NULLIF(...) in the denominator to safely handle those cases.
- Also, calculating the average transaction value in naira needed extra care. Since the raw amounts were in kobo, I had to make sure the conversion was done properly. And because I was grouping by customer, I had to double-check that the totals and averages were accurate and not being affected by the joins or groupings.
