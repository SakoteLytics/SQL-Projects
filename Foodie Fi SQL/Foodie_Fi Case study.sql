/*
========================================
		Case Study Questions
========================================

This case study is split into an initial data understanding question before diving straight into data analysis questions before finishing with 1 single extension challenge.
*/
USE [8 WEEKS OF SQL CHALLENGE]
SELECT *
FROM Foodie_fi.plans;
SELECT *
FROM Foodie_fi.subscriptions;




/*
========================================
			Customer Journey
========================================

Based off the 8 sample customers provided in the sample from the subscriptions table, 
write a brief description about each customer�s onboarding journey.
Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!
*/

SELECT 
	customer_id,
	FP.plan_id,
	FP.plan_name,
	start_date
FROM foodie_fi.subscriptions FS
JOIN foodie_fi.plans FP
	ON FS.plan_id = FP.plan_id
WHERE customer_id IN (1,2,11,13,15,16,18,19);

/*
customer_id 19
This customer signed up for trial plan and after 7 days signed up for pro monthly plan and after 2 months upgraded to pro annual.
customer_id 15
After trial plan, this customer signed for pro monthly plan and churned after 1 month, 4 days.
*/





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


--What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

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
WHERE next_date IS NULL
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



/*
===================================================
			Challenge Payment Question
===================================================

The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
once a customer churns they will no longer make payments
*/


--Which plan is giving most revenue

--custumer current plan

WITH current_plan AS ( 
SELECT
	customer_id,
	s.plan_id,
	plan_name,
	price,
	start_date,
	MAX(start_date) OVER(
		PARTITION BY customer_id) current_planD
FROM foodie_fi.subscriptions S
LEFT JOIN foodie_fi.plans p
ON S.plan_id = p.plan_id 
--WHERE s.plan_id <> 4
)
SELECT 
	plan_name,
	COUNT(customer_id) no_of_customers,
	SUM(price) revenue
FROM current_plan
WHERE start_date = current_planD
GROUP BY plan_name
ORDER BY revenue DESC

SELECT * FROM foodie_fi.plans

SELECT 
	plan_name,
	COUNT(customer_id),
	SUM(price) price_by,
	ROUND(SUM(price)/COUNT(customer_id),2) proof
FROM foodie_fi.subscriptions s
LEFT JOIN foodie_fi.plans p
ON s.plan_id = p.plan_id
GROUP BY plan_name
ORDER BY price_by



/*
===================================================
			Outside The Box Questions
===================================================

The following are open ended questions which might be asked during a technical interview for this case study 
there are no right or wrong answers, but answers that make sense from both a technical and a business perspective make an amazing impression!
*/


--1. How would you calculate the rate of growth for Foodie-Fi?

--Monthly subscriber growth rate
--MRR- Monthly Recurring Revenue

--This is the growth rate for Foodie_Fi in 2020 - Monthly subscriber growth rate

WITH monthly_subscription AS(
SELECT
	DATEPART(MONTH,start_date) month,
	DATENAME(MONTH,start_date) month_Name,
	CAST(COUNT(customer_id) AS FLOAT) subscribers
FROM foodie_fi.subscriptions
WHERE plan_id = 0 AND YEAR(start_date) = 2020
GROUP BY 
	DATEPART(MONTH,start_date),
	DATENAME(MONTH,start_date)
), MOM_Growth_Rate AS (
SELECT 
	month_name,
	subscribers,
	LAG(subscribers) OVER(ORDER BY month) AS previous_month_subscribers,
	ROUND(((subscribers - LAG(subscribers) OVER(ORDER BY month))/LAG(subscribers) OVER(ORDER BY month))
	*100.00,2) AS Growth_rate
FROM monthly_subscription
)
SELECT 
	month_name,
	Growth_rate
FROM MOM_Growth_Rate


--This is the growth rate for Foodie_Fi in 2020 - MRR- Monthly Recurring Revenue

--2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?

--Total active subscribers
--Monthly subscriber growth rate
--monthly recurring revenue
--churn rate
--new subscriber per month
--Trial-to-paid conversion rate
--average revenue per user (ARPU)
--Average subscription Duration/customer lifetime
--Revenue by plan type
--churn reason analysis.SURVEY WORKS



--3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?

--Trial conversion Journey
--Plan upgrade/downgrade patterns
--subscription longetivity plan
--Churn timing


--4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?

--what is the main reason you are canceling your subscription? Multiple-choice
--On a scale of 1-5, how satisfied were you with your foodie-fi experience
--would you consider resubscribing in the future? (Yes, No, Maybe)
--what could we improve to make you stay? Open-ended


--5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?




/*
===================================================
				Total Year Value
===================================================
*/
SELECT
	s.customer_id,
	s.plan_id,
	s.start_date,
	p.price,
	ROW_NUMBER() OVER(
		PARTITION BY customer_id
		ORDER BY start_date),
	DATEDIFF(MONTH, start_date, '2020-12-31') months_subscribed,
-- Total Revenue from each customer for 2020. From their Start Date.
	CASE
		WHEN s.plan_id = 0 THEN price
		WHEN s.plan_id = 4 THEN price
	ELSE price*DATEDIFF(MONTH, start_date, '2020-12-31')
	END AS Total2020
FROM foodie_fi.subscriptions s
JOIN foodie_fi.plans p
ON s.plan_id = p.plan_id;

--END DATE OF SUBSCRIPTION. IF NOT CHURNED USE END OF YEAR '2020-12-31'

WITH End_of_subscription AS (
SELECT
	s.customer_id,
	s.plan_id,
	s.start_date,
	p.price,
--The Date the customer moved to the next plan (7 days for all trial plan)
	LEAD(start_date) OVER(
		PARTITION BY customer_id ORDER BY start_date) AS next_dates,
-- END OF SUBSCRIPTION 2020: '2020-12-31' as end of subscription,used churn date as end of subscription for churned customer
	CASE
		WHEN LEAD(start_date) OVER(
			PARTITION BY customer_id ORDER BY start_date)	IS NULL AND p.price IS NOT NULL THEN '2020-12-31'
		ELSE LEAD(start_date) OVER(
				PARTITION BY customer_id ORDER BY start_date)
	END AS End_Date
FROM foodie_fi.subscriptions s
LEFT JOIN foodie_fi.plans p
ON s.plan_id = p.plan_id
WHERE YEAR(start_date) = 2020 
)
SELECT
	*,
	DATEDIFF(DAY,start_date,End_Date) AS no_of_days_subscribed,
	CASE
		WHEN plan_id = 0 OR plan_id = 4 THEN NULL
		ELSE MONTH(DATEDIFF(DAY,start_date,End_Date))
	END AS months_subscribed,
	price * (CASE
				WHEN plan_id = 0 OR plan_id = 4 THEN NULL
				ELSE MONTH(DATEDIFF(DAY,start_date,End_Date))
			END) AS revenue_2020
FROM End_of_subscription