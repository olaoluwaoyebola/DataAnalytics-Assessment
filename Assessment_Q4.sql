USE adashi_staging;

# Marketing wants to estimate CLV based on account tenure and transaction volume (simplified model).

/* For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
● Account tenure (months since signup)
● Total transactions
● Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
● Order by estimated CLV from highest to lowest */

SELECT
	uc.id AS customer_id,
    CONCAT(uc.first_name, ' ', uc.last_name) AS name,
    TIMESTAMPDIFF(MONTH, uc.date_joined, CURRENT_DATE) AS tenure_months,	# this returns the no. of months the account has been opened for
    COUNT(ss.id) AS total_transactions,
    ROUND(
		(COUNT(ss.id) / TIMESTAMPDIFF(MONTH, uc.date_joined, CURRENT_DATE)) 
        * 12 * ((SUM(ss.confirmed_amount) / COUNT(ss.id)) * 0.001) / 100,2
	) AS estimated_clv
    
    /* ROUND rounds up the clv to 2 decimal places. the enntire clv calculation is divided by 100
    to convert the value from kobo to naira */
    
FROM users_customuser uc
JOIN savings_savingsaccount ss
ON uc.id = ss.owner_id
WHERE ss.confirmed_amount IS NOT NULL #filters the table to ensure only accounts with valid transactions are selected
GROUP BY uc.id
ORDER BY estimated_clv DESC;