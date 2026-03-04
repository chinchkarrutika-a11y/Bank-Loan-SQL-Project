-- ==========================================
-- Data Cleaning & Transformation
-- ==========================================

SET SQL_SAFE_UPDATES = 0;

-- Insert Cleaned Data
INSERT INTO loans (
loan_id, customer_id, loan_amount, interest_rate,
annual_income, state, loan_grade, loan_status,
issue_date, issue_year, issue_month, dti
)
SELECT
loan_id,
customer_id,
CAST(NULLIF(TRIM(loan_amount),'') AS DECIMAL(12,2)),
CAST(NULLIF(REPLACE(TRIM(interest_rate),'%',''),'') AS DECIMAL(5,2)),
CAST(NULLIF(TRIM(annual_income),'') AS DECIMAL(15,2)),
state,
loan_grade,
loan_status,
STR_TO_DATE(issue_date,'%Y-%m-%d'),
YEAR(STR_TO_DATE(issue_date,'%Y-%m-%d')),
MONTH(STR_TO_DATE(issue_date,'%Y-%m-%d')),
CAST(NULLIF(TRIM(dti),'') AS DECIMAL(6,2))
FROM staging_loans
WHERE TRIM(loan_amount) <> '';

-- Income Band
UPDATE loans
SET income_band =
CASE
WHEN annual_income < 300000 THEN 'Low'
WHEN annual_income BETWEEN 300000 AND 600000 THEN 'Medium'
ELSE 'High'
END;

-- DTI Band
UPDATE loans
SET dti_band =
CASE
WHEN dti < 15 THEN 'Low DTI'
WHEN dti BETWEEN 15 AND 30 THEN 'Medium DTI'
ELSE 'High DTI'
END;

-- Risk Flag
UPDATE loans
SET risk_flag =
CASE
WHEN loan_status='Charged Off' THEN 'High Risk'
WHEN dti > 30 THEN 'Medium Risk'
ELSE 'Low Risk'
END;

-- Estimated Interest
UPDATE loans
SET estimated_interest = loan_amount * (interest_rate/100);

SET SQL_SAFE_UPDATES = 1;