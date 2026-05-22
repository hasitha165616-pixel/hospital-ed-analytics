USE healthcare_analysis;
SELECT COUNT(*) FROM patients;

-- Total patients and key metrics
SELECT 
    COUNT(*) as total_patients,
    ROUND(AVG(`Billing Amount`), 2) as avg_billing,
    ROUND(AVG(`Length of Stay`), 2) as avg_stay,
    MIN(`Date of Admission`) as earliest_admission,
    MAX(`Date of Admission`) as latest_admission
FROM patients;

-- Patient count and avg billing by medical condition
SELECT 
    `Medical Condition`,
    COUNT(*) as patient_count,
    ROUND(AVG(`Billing Amount`), 2) as avg_billing,
    ROUND(AVG(`Length of Stay`), 2) as avg_stay
FROM patients
WHERE `Billing Amount` > 0  -- exclude anomalies
GROUP BY `Medical Condition`
ORDER BY avg_billing DESC;

-- Compare Emergency vs Urgent vs Elective
SELECT 
    `Admission Type`,
    COUNT(*) as admissions,
    ROUND(AVG(`Billing Amount`), 2) as avg_billing,
    ROUND(AVG(`Length of Stay`), 2) as avg_stay_days,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM patients), 2) as pct_of_total
FROM patients
GROUP BY `Admission Type`
ORDER BY admissions DESC;

-- Which insurance pays the most on average?
SELECT 
    `Insurance Provider`,
    COUNT(*) as patient_count,
    ROUND(AVG(`Billing Amount`), 2) as avg_billing,
    ROUND(SUM(`Billing Amount`), 2) as total_revenue
FROM patients
WHERE `Billing Amount` > 0
GROUP BY `Insurance Provider`
ORDER BY avg_billing DESC;

-- Top doctors by patient volume
SELECT 
    Doctor,
    COUNT(*) as patients_handled,
    ROUND(AVG(`Billing Amount`), 2) as avg_billing_per_patient,
    RANK() OVER (ORDER BY COUNT(*) DESC) as doctor_rank
FROM patients
GROUP BY Doctor
ORDER BY patients_handled DESC
LIMIT 20;

-- Admissions by month
SELECT 
    DATE_FORMAT(`Date of Admission`, '%Y-%m') as month,
    COUNT(*) as monthly_admissions,
    ROUND(AVG(`Billing Amount`), 2) as avg_monthly_billing
FROM patients
GROUP BY month
ORDER BY month;

-- Which conditions have most abnormal results?
SELECT 
    `Medical Condition`,
    `Test Results`,
    COUNT(*) as result_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY `Medical Condition`), 2) as pct_within_condition
FROM patients
GROUP BY `Medical Condition`, `Test Results`
ORDER BY `Medical Condition`, result_count DESC;

-- Billing and stay patterns by age group
SELECT 
    `Age Group`,
    COUNT(*) as patients,
    ROUND(AVG(`Billing Amount`), 2) as avg_billing,
    ROUND(AVG(`Length of Stay`), 2) as avg_stay,
    ROUND(AVG(Age), 1) as avg_age_in_group
FROM patients
WHERE `Age Group` IS NOT NULL
GROUP BY `Age Group`
ORDER BY 
    CASE `Age Group`
        WHEN '0-18' THEN 1
        WHEN '19-35' THEN 2
        WHEN '36-55' THEN 3
        WHEN '56-75' THEN 4
        WHEN '75+' THEN 5
    END;