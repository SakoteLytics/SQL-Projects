
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
FROM MOM_Growth_Rate;


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
			PARTITION BY customer_id ORDER BY start_date) IS NULL AND p.price IS NOT NULL THEN '2020-12-31'
		WHEN S.plan_id = 4 THEN start_date
		ELSE LEAD(start_date) OVER(
				PARTITION BY customer_id ORDER BY start_date)
	END AS End_Date
FROM foodie_fi.subscriptions s
LEFT JOIN foodie_fi.plans p
ON s.plan_id = p.plan_id
WHERE YEAR(start_date) = 2020 
)
SELECT
	customer_id,
	plan_id,
	start_date,
	End_Date,
	CASE
		WHEN plan_id = 0 OR plan_id = 4 THEN 0
		ELSE MONTH(DATEDIFF(DAY,start_date,End_Date))
	END AS months_subscribed,
	price * (CASE
				WHEN plan_id = 0 OR plan_id = 4 THEN 0
				ELSE MONTH(DATEDIFF(DAY,start_date,End_Date))
			END) AS revenue_2020
FROM End_of_subscription
