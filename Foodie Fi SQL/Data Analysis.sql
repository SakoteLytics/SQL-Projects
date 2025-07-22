

/*
====================================================
			Data Analysis Questions
====================================================
*/

--How many customers has Foodie-Fi ever had?

SELECT COUNT (DISTINCT customer_id) AS Total_Customers
FROM foodie_fi.subscriptions;


--What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

SELECT
	DATEPART(MONTH,start_date) Month,
	DATENAME(MONTH,start_date) Month_Name,
	COUNT(customer_id) Trial_plans
FROM foodie_fi.subscriptions
WHERE plan_id = 0
GROUP BY 
	DATEPART(MONTH,start_date),
	DATENAME(MONTH,start_date)
ORDER BY Month;

--What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

SELECT
	s.plan_id,
	plan_name,
	COUNT(start_date) Num_of_events
FROM foodie_fi.subscriptions s
LEFT JOIN foodie_fi.plans p
	ON s.plan_id = p.plan_id
WHERE DATEPART(YEAR,start_date) = 2021
GROUP BY
	s.plan_id,
	plan_name
ORDER BY Num_of_events;


--What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT
	COUNT(customer_id) churn_customers,
	CAST((100.0*COUNT(customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions)) AS DECIMAL(3,1)) Churned_Percentage
FROM foodie_fi.subscriptions s
LEFT JOIN foodie_fi.plans p
	ON s.plan_id = p.plan_id
WHERE plan_name = 'churn';



--How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?


WITH Ranked_CTE AS (
SELECT
	customer_id,
	plan_name,
	ROW_NUMBER() OVER (
		PARTITION BY s.customer_id 
		ORDER BY s.start_date) AS row_num
FROM foodie_fi.subscriptions s
LEFT JOIN foodie_fi.plans p
	ON s.plan_id = p.plan_id
)
SELECT 
	COUNT(customer_id) [churned straight customers],
	FORMAT(COUNT(customer_id)*1.0/(SELECT COUNT (DISTINCT customer_id) FROM foodie_fi.subscriptions),'P') [percentage]
FROM Ranked_CTE
WHERE plan_name = 'churn' AND row_num = 2;



--What is the number and percentage of customer plans after their initial free trial?


WITH next_plans AS (
SELECT 
	s.customer_id,
	p.plan_id,
	p.plan_name,
	s.start_date,
	ROW_NUMBER() OVER(
		PARTITION BY s.customer_id
		ORDER BY start_date) row_num
FROM foodie_fi.subscriptions s
LEFT JOIN foodie_fi.plans p
	ON s.plan_id = p.plan_id
)
SELECT
	plan_id,
	plan_name,
	COUNT(customer_id) [number of customer plan],
	FORMAT(COUNT(customer_id)*1.00/(SELECT COUNT (DISTINCT customer_id) FROM foodie_fi.subscriptions),'P') [percentage]
FROM next_plans
WHERE row_num = 2
GROUP BY 
	plan_id,
	plan_name
ORDER BY plan_id ASC;


--What is the customer count and percentage breakdown of all plan_name values at 2020-12-31?

-- trial plan is 100% because every customer used the trial plan
WITH Next_dates AS (
SELECT 
	customer_id,
	plan_id,
	start_date,
	LEAD(start_date) OVER(
		PARTITION BY customer_id
		ORDER BY start_date) next_date
FROM foodie_fi.subscriptions
WHERE start_date <= '2020-12-31'
)
SELECT
	plan_name,
	COUNT(plan_name) Customer_count,
	FORMAT(1.00*COUNT(plan_name) / (SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions), 'P') Percentage
FROM Next_dates ND
LEFT JOIN foodie_fi.plans P
	ON ND.plan_id = P.plan_id
GROUP BY 
	plan_name
ORDER BY Customer_count;

--How many customers have upgraded to an annual plan in 2020?

SELECT 
	COUNT(customer_id) Annual_plan_Customers
FROM foodie_fi.subscriptions
WHERE plan_id = 3 AND start_date <= '2020-12-31';



--How many days on average does it take for a customer to upgrade to an annual plan from the day they join Foodie-Fi?


WITH annual_plan AS (
SELECT
	customer_id,
	start_date,
	LAG(start_date) OVER(
		PARTITION BY customer_id
		ORDER BY start_date) annual_date
FROM foodie_fi.subscriptions
WHERE plan_id IN (0,3)
)
SELECT
	AVG(DATEDIFF(DAY, annual_date, start_date)) Avg_days_to_upgrade
FROM annual_plan AP;



--Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)


WITH trial_plan AS (
  SELECT 
    customer_id, 
    start_date AS trial_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 0
), annual_plan AS (
  SELECT 
    customer_id, 
    start_date AS annual_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 3
 ), average_value AS(
 SELECT
	(DATEDIFF(DAY, trial_date, annual_date)) days_to_upgrade
FROM annual_plan AP
INNER JOIN trial_plan TP
ON AP.customer_id = TP.customer_id
)
SELECT 
  CASE 
    WHEN days_to_upgrade BETWEEN 0 AND 30 THEN '0-30 days'
    WHEN days_to_upgrade BETWEEN 31 AND 60 THEN '31-60 days'
    WHEN days_to_upgrade BETWEEN 61 AND 90 THEN '61-90 days'
    WHEN days_to_upgrade BETWEEN 91 AND 120 THEN '91-120 days'
    WHEN days_to_upgrade BETWEEN 121 AND 150 THEN '121-150 days'
    WHEN days_to_upgrade BETWEEN 151 AND 180 THEN '151-180 days'
    WHEN days_to_upgrade BETWEEN 181 AND 210 THEN '181-210 days'
    WHEN days_to_upgrade BETWEEN 211 AND 240 THEN '211-240 days'
    WHEN days_to_upgrade BETWEEN 241 AND 270 THEN '241-270 days'
    WHEN days_to_upgrade BETWEEN 271 AND 300 THEN '271-300 days'
    WHEN days_to_upgrade BETWEEN 301 AND 330 THEN '301-330 days'
    WHEN days_to_upgrade BETWEEN 331 AND 365 THEN '331-365 days'
    ELSE 'Over 365 days'
  END AS bucket,
  COUNT(*) AS num_of_customers
FROM average_value
GROUP BY
	CASE 
		WHEN days_to_upgrade BETWEEN 0 AND 30 THEN '0-30 days'
		WHEN days_to_upgrade BETWEEN 31 AND 60 THEN '31-60 days'
		WHEN days_to_upgrade BETWEEN 61 AND 90 THEN '61-90 days'
		WHEN days_to_upgrade BETWEEN 91 AND 120 THEN '91-120 days'
		WHEN days_to_upgrade BETWEEN 121 AND 150 THEN '121-150 days'
		WHEN days_to_upgrade BETWEEN 151 AND 180 THEN '151-180 days'
		WHEN days_to_upgrade BETWEEN 181 AND 210 THEN '181-210 days'
		WHEN days_to_upgrade BETWEEN 211 AND 240 THEN '211-240 days'
		WHEN days_to_upgrade BETWEEN 241 AND 270 THEN '241-270 days'
		WHEN days_to_upgrade BETWEEN 271 AND 300 THEN '271-300 days'
		WHEN days_to_upgrade BETWEEN 301 AND 330 THEN '301-330 days'
		WHEN days_to_upgrade BETWEEN 331 AND 365 THEN '331-365 days'
		ELSE 'Over 365 days'
	END
ORDER BY num_of_customers DESC;


--How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

WITH Customers_monthly_downgrade AS (
	SELECT
		customer_id,
		plan_id,
		start_date,
		LAG(plan_id) OVER(
			PARTITION BY customer_id
			ORDER BY start_date) prev_plan
	FROM foodie_fi.subscriptions
	WHERE start_date <= '2020-12-31'
)
SELECT 
	*
FROM Customers_monthly_downgrade
WHERE prev_plan = 2 
	AND plan_id = 1
