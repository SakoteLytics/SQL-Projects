/*
===================================================
				Payment Question
===================================================

The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
once a customer churns they will no longer make payments
*/




-- Drop payments table if it exists
IF OBJECT_ID('payments', 'U') IS NOT NULL
    DROP TABLE payments;

-- Step-by-step logic with CTEs
WITH plan_details AS (
  SELECT 
    s.customer_id,
    s.plan_id,
    p.plan_name,
    p.price,
    s.start_date
  FROM foodie_fi.subscriptions s
  JOIN foodie_fi.plans p 
  ON s.plan_id = p.plan_id
  WHERE s.start_date < '2021-01-01'
),

churns AS (
  SELECT 
  customer_id,
  start_date AS churn_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 4 -- Churn
),

-- Monthly recurring payments: pro monthly and basic monthly
monthly_payments AS (
  SELECT 
    pd.customer_id,
    pd.plan_id,
    pd.plan_name,
    DATEADD(MONTH, n.n, pd.start_date) AS payment_date,
    pd.price AS amount
  FROM plan_details pd
  JOIN (
    SELECT 0 AS n UNION ALL 
	SELECT 1 UNION ALL 
	SELECT 2 UNION ALL
    SELECT 3 UNION ALL 
	SELECT 4 UNION ALL 
	SELECT 5 UNION ALL
    SELECT 6 UNION ALL 
	SELECT 7 UNION ALL 
	SELECT 8 UNION ALL
    SELECT 9 UNION ALL 
	SELECT 10 UNION ALL 
	SELECT 11
  ) n 
  ON pd.plan_name IN ('basic monthly', 'pro monthly')
  LEFT JOIN churns c 
  ON pd.customer_id = c.customer_id
  WHERE DATEADD(MONTH, n.n, pd.start_date) < '2021-01-01'
    AND (
      c.churn_date IS NULL OR
      DATEADD(MONTH, n.n, pd.start_date) < c.churn_date
    )
),

-- One-time plans: trial, pro annual (initial)
one_time_payments AS (
  SELECT 
    customer_id,
    plan_id,
    plan_name,
    start_date AS payment_date,
    price AS amount
  FROM plan_details
  WHERE plan_name IN ('trial')
),
-- Basic to Pro/Monthly upgrade — pay difference immediately
basic_upgrades AS (
  SELECT 
    u.customer_id,
    u.plan_id,
    p_new.plan_name,
    u.start_date AS payment_date,
    (p_new.price - p_old.price) AS amount
  FROM foodie_fi.subscriptions u
  JOIN foodie_fi.subscriptions b 
  ON 
	u.customer_id = b.customer_id AND
    b.plan_id = 1 AND -- basic
    b.start_date < u.start_date
  JOIN foodie_fi.plans p_new 
  ON u.plan_id = p_new.plan_id
  JOIN foodie_fi.plans p_old 
  ON b.plan_id = p_old.plan_id
  WHERE 
    p_new.plan_name IN ('pro monthly', 'basic monthly') AND
    MONTH(u.start_date) = MONTH(b.start_date) AND
    YEAR(u.start_date) = YEAR(b.start_date)
),
-- Pro Monthly to Pro Annual: pay pro annual at end of current month
pro_to_annual AS (
  SELECT 
    u.customer_id,
    u.plan_id,
    p_new.plan_name,
    DATEADD(MONTH, 1, u.start_date) AS payment_date,
    p_new.price AS amount
  FROM foodie_fi.subscriptions u
  JOIN foodie_fi.plans p_new ON u.plan_id = p_new.plan_id
  JOIN foodie_fi.subscriptions pm ON 
    pm.customer_id = u.customer_id AND
    pm.plan_id = 2 AND -- pro monthly
    pm.start_date < u.start_date
  WHERE 
    u.plan_id = 3 -- pro annual
),
-- Combine all payments
all_payments AS (
  SELECT * FROM monthly_payments
  UNION ALL
  SELECT * FROM one_time_payments
  UNION ALL
  SELECT * FROM basic_upgrades
  UNION ALL
  SELECT * FROM pro_to_annual
)

-- Final output with payment order
SELECT 
  customer_id,
  plan_id,
  plan_name,
  payment_date,
  CAST(amount AS DECIMAL(5,2)) AS amount,
  RANK() OVER (PARTITION BY customer_id ORDER BY payment_date) AS payment_order
INTO foodie_fi.payments
FROM all_payments
ORDER BY customer_id, payment_date;


-- Preview the final result
SELECT * FROM foodie_fi.payments;