# FOODIE FI STREAMING SERVICE

This project is part of the [8 Week SQL Challenge](https://8weeksqlchallenge.com/case-study-2/) — a series of real-world SQL case studies.

_**Foodie-Fi** is a fictional food subscription service offering different subscription plans. In this case study, I used SQL to analyze customer subscriptions, upgrades, churn, and revenue across the 2020 calendar year._

Foodie-Fi is a subscription-based streaming service focused on food-related content, like a "Netflix for cooking shows". It was founded in 2020 by Danny and a team of his friends, offering monthly and annual subscriptions for on-demand access to exclusive food videos from around the world. Foodie-Fi is data-driven, aiming to use data to inform all future investment decisions and new feature development.


## Foodie-Fi Data Schema Overview
Foodie-Fi is a fictional company offering subscription plans for food-related digital content. The dataset mimics a SaaS (Software as a Service) model where customers can:

- Start with a free trial
- Upgrade to basic, pro monthly, or pro annual plan
- Or churn (cancel)


### A. Plan Table

| Column      | Type    | Description                                  |
| ----------- | ------- | -------------------------------------------- |
| `plan_id`   | INT     | Unique ID for each subscription plan         |
| `plan_name` | VARCHAR | Name of the plan |
| `price`     | INT     | Price of the plan in dollars |


| plan\_id | plan\_name | price(USD) |
| -------- | ---------- | ----- |
| 0      | trial         | 0.00    |
| 1      | basic monthly | 9.90    |
| 2      | pro monthly   | 19.90   |
| 3      | pro monthly   | 199.00  |
| 4      | churn         | NULL    |


### B. Subscription Table


| Column        | Type | Description                               |
| ------------- | ---- | ----------------------------------------- |
| `customer_id` | INT  | Unique ID of the customer                 |
| `plan_id`     | INT  | Foreign key referencing the `plans` table |
| `start_date`  | DATE | The date the customer started this plan  |

Sample Table

| customer\_id | plan\_id | start\_date |
| ------------ | -------- | ----------- |
| 1            | 0        | 2020-01-01  |
| 1            | 1        | 2020-01-08  |
| 1            | 4        | 2020-02-01  |

[View Foodie-Fi Sql Schema file](Foodie_Fi%20Schema.sql)


## Key Business Questions Solved

- How many customers joined each plan?
- What percentage of customers churned after each plan?
- What is the average time spent on the free trial before upgrades?
- How much revenue was generated in 2020?
- How many upgrades occurred each month?

## Notable SQL Techniques Used

- Common Table Expressions (CTEs)
- CASE statements and conditional logic
- DATEADD and DATEDIFF functions
- LEFT JOINs and subqueries
- Aggregations and window functions

## What I Learned

- Translating real-world business rules into SQL logic
- Building time-based customer journey tracking
- Managing upgrade and churn conditions within payment logic
- Structuring a clean and modular SQL workflow
- Documenting SQL projects in a developer-friendly way

---

Acknowledgements

Challenge by Danny Ma – 8 Week SQL Challenge
