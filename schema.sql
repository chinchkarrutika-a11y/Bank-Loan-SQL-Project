-- ==========================================
-- Bank Loan Risk & Performance Analysis
-- Database Schema
-- ==========================================

CREATE DATABASE bank_loan_project;
USE bank_loan_project;

-- RAW TABLE
CREATE TABLE raw_loans (
    loan_id INT,
    customer_id INT,
    loan_amount VARCHAR(50),
    interest_rate VARCHAR(20),
    annual_income VARCHAR(50),
    state VARCHAR(10),
    loan_grade VARCHAR(5),
    loan_status VARCHAR(30),
    issue_date VARCHAR(30),
    dti VARCHAR(20)
);

-- STAGING TABLE
CREATE TABLE staging_loans AS
SELECT DISTINCT * FROM raw_loans;

-- FINAL ANALYTICS TABLE
CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    loan_amount DECIMAL(12,2) NOT NULL,
    interest_rate DECIMAL(5,2),
    annual_income DECIMAL(15,2),
    income_band VARCHAR(20),
    state VARCHAR(10),
    loan_grade VARCHAR(5),
    loan_status VARCHAR(30),
    issue_date DATE,
    issue_year INT,
    issue_month INT,
    dti DECIMAL(6,2),
    dti_band VARCHAR(20),
    risk_flag VARCHAR(20),
    estimated_interest DECIMAL(15,2)
);

-- Indexes
CREATE INDEX idx_state ON loans(state);
CREATE INDEX idx_issue_date ON loans(issue_date);
CREATE INDEX idx_grade ON loans(loan_grade);
CREATE INDEX idx_status ON loans(loan_status);
CREATE INDEX idx_customer ON loans(customer_id);