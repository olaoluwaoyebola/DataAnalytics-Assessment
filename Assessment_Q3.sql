USE adashi_staging;

# Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days) .

SELECT 
	pp.id AS plan_id, 
	pp.owner_id,
    CASE 
		WHEN pp.is_regular_savings = '1' THEN 'Savings'
        WHEN pp.is_a_fund = '1' THEN 'Investment'
	END AS type,	
	MAX(ss.transaction_date) AS last_transaction_date,	
	DATEDIFF(CURRENT_DATE, MAX(ss.transaction_date)) AS inactivity_days
    
/* the case function is used here to set the type of account  
max is used to get the most recent date
datediff returns the number of days between two date values, 
in this case it shows the length of time since the last transaction */

FROM plans_plan pp
LEFT JOIN savings_savingsaccount ss ON pp.id = ss.plan_id
	AND ss.confirmed_amount IS NOT NULL		# filters only accounts with valid inflow transactions to aid calculation of inactive days
WHERE pp.status_id = 1
	AND (pp.is_regular_savings = 1 OR pp.is_a_fund = 1)	# this ensures we're dealing with only active savings and investment plans
GROUP BY 
	pp.id,
    pp.owner_id,
    CASE
		WHEN pp.is_regular_savings = '1' THEN 'Savings'
        WHEN pp.is_a_fund = '1' THEN 'Investment'
	END
HAVING
	MAX(ss.transaction_date) < DATE_SUB(CURRENT_DATE, INTERVAL 365 DAY)
    OR MAX(ss.transaction_date) IS NULL
ORDER BY inactivity_days DESC;	# diplays output from larget inactivity days to smallest