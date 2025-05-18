USE adashi_staging;

/*Write a query to find customers with at least one funded savings plan AND one
funded investment plan, sorted by total deposits.*/

SELECT 
	uc.id AS owner_id,
    CONCAT(uc.first_name,' ',uc.last_name) AS name,		# merging the first name with last name into a new column
    SUM(CASE WHEN is_regular_savings = '1' THEN 1 ELSE 0 END) AS savings_count,
    SUM(CASE WHEN is_a_fund = '1' THEN 1 ELSE 0 END) AS investment_count,
    SUM(pp.amount) AS total_deposits
FROM users_customuser uc 
INNER JOIN savings_savingsaccount ss ON uc.id = ss.owner_id		# attached each customer with their savings account
INNER JOIN plans_plan pp ON pp.id = ss.plan_id			# attached savings plan to the corresponding savings account 
WHERE pp.amount > 0			# filters the data to display only customers that has funded their savings plan 
GROUP BY uc.id
HAVING
	SUM(CASE WHEN is_regular_savings = '1' THEN 1 ELSE 0 END) > 0 
	AND SUM(CASE WHEN is_a_fund = '1' THEN 1 ELSE 0 END) > 0
ORDER BY total_deposits DESC;