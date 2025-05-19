# Cowrywise_assessment
##  High-Value Customers with Multiple Products
Goal of the Query
- The query retrieves a list of all users along with:
- Their email and full name
- Their total savings amount
- Their total investment amount
- Their combined total deposit (savings + investment)
- The results are sorted by total deposit in descending order, so the highest value customers appear first.
- ![high value cusomers.sql]

## Transaction Frequency Analysis
Goal of the Query
- Segment users based on how frequently they make successful savings transactions per month:
    High Frequency: ≥ 10 transactions/month
    Medium Frequency: 3–9 transactions/month
    Low Frequency: ≤ 2 transactions/month
- The final result shows:
- Frequency category
- Number of users in each category
- Average transactions per month for each group

## Account Inactivity Alert
Goal of the Query
- Identify inactive accounts:
    Find all active savings and investment accounts that have had no successful transactions in the last 365 days (i.e., inactive for over a year).
- Distinguish account types:
    Separate the inactive accounts into two types:
- Savings accounts (from savings_savingsaccount)
- Investment plans (from plans_plan where plan_type_id = 1)
- Report last activity and inactivity duration:
- For each inactive account, report:
    The last transaction date or last activity date (transaction_date for savings, created_on for investments)
- How many days have passed since that last transaction (inactivity_days)
- Provide a summary view for operations:
- Enable the operations team to quickly flag accounts that have not had any money inflow for over a year so they can investigate, reach out, or take necessary actions like account review or follow-up.

## Customer Lifetime Value
The Goal of the Query 
- To estimate the Customer Lifetime Value (CLV) for each customer based on their account tenure and transaction history, using the following approach:
- Calculate account tenure:
It computes how many months each customer has been active since they joined (tenure_months).
- Count total transactions:
It counts the total number of successful transactions the customer has made (total_transactions).
- Estimate CLV:
Using a simplified model, it estimates the CLV by:
- Calculating the average monthly transactions (total_transactions / tenure_months), scaling this to an annual basis (* 12), multiplying by the average profit per transaction (assumed as 0.1% of transaction amount, represented by amount * 0.001)
- This gives an estimated annual profit value per customer, rounded to 2 decimals.
- Order customers by CLV:
The result is sorted to show customers with the highest estimated lifetime value at the top.



