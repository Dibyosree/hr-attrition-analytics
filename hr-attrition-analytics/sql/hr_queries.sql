/* =====================================================================
   PROJECT: HR Attrition & Workforce Analytics
   DATASET: WA_Fn-UseC_-HR-Employee-Attrition.csv (IBM HR Analytics)
   AUTHOR:  Dibyosree Banerjee
   PURPOSE: Identify which employees/roles/departments carry the highest
            attrition risk, what's driving it, and what HR should do.
   ===================================================================== */


/* ---------------------------------------------------------------------
   STEP 0: Create a clean view with proper column names.
   (Needed because the CSV import loaded headers as c1, c2, c3...
   instead of recognizing the first row as column names.)
   --------------------------------------------------------------------- */
CREATE VIEW hr AS
SELECT
    CAST(c1  AS INTEGER) AS Age,
    c2  AS Attrition,
    c3  AS BusinessTravel,
    CAST(c4  AS INTEGER) AS DailyRate,
    c5  AS Department,
    CAST(c6  AS INTEGER) AS DistanceFromHome,
    CAST(c7  AS INTEGER) AS Education,
    c8  AS EducationField,
    CAST(c9  AS INTEGER) AS EmployeeCount,
    CAST(c10 AS INTEGER) AS EmployeeNumber,
    CAST(c11 AS INTEGER) AS EnvironmentSatisfaction,
    c12 AS Gender,
    CAST(c13 AS INTEGER) AS HourlyRate,
    CAST(c14 AS INTEGER) AS JobInvolvement,
    CAST(c15 AS INTEGER) AS JobLevel,
    c16 AS JobRole,
    CAST(c17 AS INTEGER) AS JobSatisfaction,
    c18 AS MaritalStatus,
    CAST(c19 AS INTEGER) AS MonthlyIncome,
    CAST(c20 AS INTEGER) AS MonthlyRate,
    CAST(c21 AS INTEGER) AS NumCompaniesWorked,
    c22 AS Over18,
    c23 AS OverTime,
    CAST(c24 AS INTEGER) AS PercentSalaryHike,
    CAST(c25 AS INTEGER) AS PerformanceRating,
    CAST(c26 AS INTEGER) AS RelationshipSatisfaction,
    CAST(c27 AS INTEGER) AS StandardHours,
    CAST(c28 AS INTEGER) AS StockOptionLevel,
    CAST(c29 AS INTEGER) AS TotalWorkingYears,
    CAST(c30 AS INTEGER) AS TrainingTimesLastYear,
    CAST(c31 AS INTEGER) AS WorkLifeBalance,
    CAST(c32 AS INTEGER) AS YearsAtCompany,
    CAST(c33 AS INTEGER) AS YearsInCurrentRole,
    CAST(c34 AS INTEGER) AS YearsSinceLastPromotion,
    CAST(c35 AS INTEGER) AS YearsWithCurrManager
FROM WA_FnUseC_HREmployeeAttrition
WHERE c1 <> 'Age';  -- skips the header row that got imported as data


/* ---------------------------------------------------------------------
   QUERY 1: Overall attrition rate
   --------------------------------------------------------------------- */
SELECT 
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM hr;


/* ---------------------------------------------------------------------
   QUERY 2: Attrition rate by department
   --------------------------------------------------------------------- */
SELECT Department,
       COUNT(*) AS total,
       SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count,
       ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM hr
GROUP BY Department
ORDER BY attrition_rate_pct DESC;


/* ---------------------------------------------------------------------
   QUERY 3: Overtime vs attrition
   Finding: employees on overtime show ~3x higher attrition (30.5% vs 10.4%)
   --------------------------------------------------------------------- */
SELECT OverTime,
       COUNT(*) AS total,
       SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count,
       ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM hr
GROUP BY OverTime;


/* ---------------------------------------------------------------------
   QUERY 4: Attrition by tenure bucket
   Finding: new hires (0-2 yrs) show the highest attrition at 34.9%
   --------------------------------------------------------------------- */
SELECT 
    CASE 
        WHEN YearsAtCompany < 2 THEN '0-2 yrs'
        WHEN YearsAtCompany BETWEEN 2 AND 5 THEN '2-5 yrs'
        WHEN YearsAtCompany BETWEEN 6 AND 10 THEN '6-10 yrs'
        ELSE '10+ yrs'
    END AS tenure_bucket,
    COUNT(*) AS total,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM hr
GROUP BY tenure_bucket
ORDER BY attrition_rate_pct DESC;


/* ---------------------------------------------------------------------
   QUERY 5: Job satisfaction & work-life balance vs attrition
   --------------------------------------------------------------------- */
SELECT JobSatisfaction, WorkLifeBalance,
       COUNT(*) AS total,
       ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM hr
GROUP BY JobSatisfaction, WorkLifeBalance
ORDER BY attrition_rate_pct DESC;


/* ---------------------------------------------------------------------
   QUERY 6: Income comparison - stayed vs left, by job role
   Finding: Sales Representatives combine low income with high attrition
   --------------------------------------------------------------------- */
SELECT JobRole,
       ROUND(AVG(CASE WHEN Attrition = 'Yes' THEN MonthlyIncome END), 0) AS avg_income_left,
       ROUND(AVG(CASE WHEN Attrition = 'No' THEN MonthlyIncome END), 0) AS avg_income_stayed
FROM hr
GROUP BY JobRole
ORDER BY avg_income_left;


/* ---------------------------------------------------------------------
   QUERY 7: Attrition rate by distance from home
   Finding: no consistent pattern - commute distance is not a strong driver
   --------------------------------------------------------------------- */
SELECT DistanceFromHome,
       COUNT(*) AS total,
       ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM hr
GROUP BY DistanceFromHome
ORDER BY DistanceFromHome;


/* ---------------------------------------------------------------------
   QUERY 8: Risk flag by department + job role
   Business logic query combining attrition rate into a decision label
   --------------------------------------------------------------------- */
SELECT Department, JobRole,
       COUNT(*) AS total_employees,
       ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct,
       CASE 
         WHEN 100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) >= 25 THEN 'High Risk'
         WHEN 100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) >= 15 THEN 'Medium Risk'
         ELSE 'Low Risk'
       END AS risk_flag
FROM hr
GROUP BY Department, JobRole
ORDER BY attrition_rate_pct DESC;
