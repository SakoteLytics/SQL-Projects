/*
========================================
			Customer Journey
========================================

write a brief description about each customer�s onboarding journey.
Try to keep it as short as possible.
*/

-- Input customer_id
DECLARE @customer_id INT = 844;

SELECT 
    FS.customer_id,
    FP.plan_id,
    FP.plan_name,
    FS.start_date
FROM foodie_fi.subscriptions FS
JOIN foodie_fi.plans FP
    ON FS.plan_id = FP.plan_id
WHERE FS.customer_id = @customer_id;


/*
CUSTOMER JOURNEY

customer_id 15
After trial plan, this customer signed for pro monthly plan and churned after 1 month, 4 days.

customer_id 19
This customer signed up for trial plan and after 7 days signed up for pro monthly plan and after 2 months upgraded to pro annual.

customer_id 205
This customer signed up for trial plan, and subscribed to the basic monthly after 7 days, then he upgraded to pro annual plan after 4 months.

customer_id 394
This customer signed up for trial plan, and subscribed to the basic monthly after 7 days, then he churned 5 months.

customer_id 510
After the trial plan, this customer subscribed to basic monthly plan, after two months pro monthly plan and after two months this customer subscribed to pro annual plan..

customer_id 844
After trial plan, customer 844 churned after 7days
*/


customer_id plan_id     plan_name     start_date
----------- ----------- ------------- ----------
394         0           trial         2020-08-17
394         1           basic monthly 2020-08-24
394         4           churn         2021-01-24
510         0           trial         2020-02-19
510         1           basic monthly 2020-02-26
510         2           pro monthly   2020-04-19
510         3           pro annual    2020-06-19
844         0           trial         2020-10-14
844         4           churn         2020-10-21
