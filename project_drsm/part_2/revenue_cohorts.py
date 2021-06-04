'''
1. DrSmile has decided to launch a monthly magazine, which costs $3 per month.
We expect the initial churn rate to be 17%.
We also expect the churn rate to stabilize over time, decreasing by 5% every month.
(In other words, the churn rate after 1 month is 17%, the churn rate after 2 months will be
16.2%, and so on.)
Assuming that the magazine will launch on Jan 1, 2021, what is the ​ minimum number of new
subscribers ​ we will need every month to reach $1,000,000 in total revenue by Dec 31, 2021?
'''

from datetime import date, timedelta
from dateutil.relativedelta import relativedelta

mag_cost = 3
rev_goal = 1_000_000
customer_count = 0
new_customers = 0
start_date = date(2021, 1, 31)
delta_period = 11

revenue_total = 0
end_date = start_date + relativedelta(months=delta_period)

while revenue_total <= rev_goal:
    counter = 0
    revenue = 0
    customer_count += 1
    cal_month_range = 13
    revenue_total = 0
    for cohort in range(11):

        churn_rate = 0.17
        churn_rate_decrease = 0.05
        monthly_customers = customer_count
        cal_month_range -= 1
        for cal_month in range(cal_month_range):
            revenue = monthly_customers * mag_cost
            revenue_total += revenue
            customers_churned = monthly_customers * churn_rate
            monthly_customers -= customers_churned
            churn_rate = churn_rate - (churn_rate * churn_rate_decrease)

print(customer_count,
      "customers are needed monthly to reach the goal of",
      round(revenue_total),
      "of cumulative revenue by 2021-12-31",
      )
