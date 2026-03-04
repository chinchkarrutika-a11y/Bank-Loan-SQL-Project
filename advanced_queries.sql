-- =====================================================
-- ADVANCED ANALYTICS QUERIES
-- Bank Loan Risk & Performance Analysis
-- =====================================================


-- 1️.CUMULATIVE LOAN DISBURSEMENT TREND (Window Function)

SELECT 
    issue_year,
    issue_month,
    SUM(loan_amount) AS monthly_total,
    SUM(SUM(loan_amount)) OVER (
        ORDER BY issue_year, issue_month
    ) AS cumulative_total
FROM loans
GROUP BY issue_year, issue_month
ORDER BY issue_year, issue_month;



-- =====================================================
-- 2️.TOP 3 CUSTOMERS PER STATE BY TOTAL LOAN AMOUNT
-- (Using RANK + CTE)
-- =====================================================

WITH ranked_customers AS (
    SELECT 
        state,
        customer_id,
        SUM(loan_amount) AS total_loan,
        RANK() OVER (
            PARTITION BY state 
            ORDER BY SUM(loan_amount) DESC
        ) AS rnk
    FROM loans
    GROUP BY state, customer_id
)

SELECT *
FROM ranked_customers
WHERE rnk <= 3
ORDER BY state, rnk;



-- =====================================================
-- 3️.PORTFOLIO SHARE % BY STATE
-- =====================================================

WITH state_exposure AS (
    SELECT 
        state,
        SUM(loan_amount) AS total_exposure
    FROM loans
    GROUP BY state
)

SELECT 
    state,
    total_exposure,
    ROUND(
        100 * total_exposure / SUM(total_exposure) OVER (), 
        2
    ) AS portfolio_share_percent
FROM state_exposure
ORDER BY portfolio_share_percent DESC;



-- =====================================================
-- 4️.DEFAULT RATE BY INCOME BAND (Advanced Segmentation)
-- =====================================================

WITH income_segment AS (
    SELECT *,
        CASE 
            WHEN annual_income < 400000 THEN 'Low'
            WHEN annual_income BETWEEN 400000 AND 800000 THEN 'Medium'
            ELSE 'High'
        END AS income_band
    FROM loans
)

SELECT 
    income_band,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 'Default' THEN 1 ELSE 0 END) AS default_count,
    ROUND(
        100 * SUM(CASE WHEN loan_status = 'Default' THEN 1 ELSE 0 END) 
        / COUNT(*),
        2
    ) AS default_rate_percent
FROM income_segment
GROUP BY income_band
ORDER BY default_rate_percent DESC;



-- =====================================================
-- 5️.RISK FLAG CREATION BASED ON DTI + GRADE
-- =====================================================

SELECT 
    loan_id,
    state,
    loan_grade,
    dti,
    CASE 
        WHEN dti > 30 AND loan_grade IN ('C','D') THEN 'High Risk'
        WHEN dti BETWEEN 20 AND 30 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_flag
FROM loans;



-- =====================================================
-- 6️⃣ INTEREST REVENUE ESTIMATION PER STATE
-- =====================================================

SELECT 
    state,
    ROUND(SUM(loan_amount * interest_rate / 100), 2) AS estimated_interest_revenue
FROM loans
GROUP BY state
ORDER BY estimated_interest_revenue DESC;



-- =====================================================
-- 7️.DEFAULT EXPOSURE AMOUNT BY GRADE
-- =====================================================

SELECT 
    loan_grade,
    SUM(CASE 
            WHEN loan_status = 'Default' 
            THEN loan_amount 
            ELSE 0 
        END) AS default_exposure
FROM loans
GROUP BY loan_grade
ORDER BY default_exposure DESC;



-- =====================================================
-- 8️.YEAR-OVER-YEAR GROWTH IN LOAN DISBURSEMENT
-- =====================================================

WITH yearly_totals AS (
    SELECT 
        issue_year,
        SUM(loan_amount) AS yearly_total
    FROM loans
    GROUP BY issue_year
)

SELECT 
    issue_year,
    yearly_total,
    LAG(yearly_total) OVER (ORDER BY issue_year) AS previous_year,
    ROUND(
        100 * (yearly_total - LAG(yearly_total) OVER (ORDER BY issue_year)) 
        / LAG(yearly_total) OVER (ORDER BY issue_year),
        2
    ) AS yoy_growth_percent
FROM yearly_totals
ORDER BY issue_year;