# HR Attrition & Workforce Analytics

## Business Question
Which employees, roles, and departments carry the highest attrition risk, what factors are actually driving people to leave, and what should HR prioritize to improve retention?

## Tools Used
- **SQL (SQLite)** — data cleaning, aggregation, and business-logic (risk-flagging) queries
- **Power BI** — DAX measures, calculated columns, and a 4-page interactive dashboard
- **Dataset**: IBM HR Analytics Employee Attrition dataset — 1,470 employees, 35 columns, no missing values

## Key Findings

1. **Overtime is the single strongest predictor of attrition.** Employees working overtime show a 30.5% attrition rate versus 10.4% for those who don't — nearly a 3x gap.

2. **New hires are the highest flight risk.** Employees with 0–2 years of tenure show 34.9% attrition, dropping steadily to 8.1% for employees with 10+ years at the company.

3. **Sales Representatives have the highest attrition of any role (39.8%)** — more than double the company-wide average of 16.1%.

4. **Job satisfaction shows a clear inverse relationship with attrition** — 22.8% attrition at the lowest satisfaction level versus 11.3% at the highest.

5. **Distance from home shows no consistent relationship with attrition** — commute length does not appear to be a meaningful driver, an important negative finding that avoids over-fitting a story to the data.

## Recommendations
- Audit workload distribution and overtime policy, particularly within Sales, where overtime and attrition both run highest
- Strengthen onboarding, early mentorship, and structured 90-day check-ins to address the new-hire attrition spike
- Conduct a targeted retention review (compensation benchmarking + workload analysis) specifically for the Sales Representative role
- Introduce regular pulse surveys and manager training focused on catching early satisfaction decline
- Deprioritize remote/hybrid policy changes as a retention lever — the data doesn't support commute distance as a driver

## Project Structure
```
/data        → WA_Fn-UseC_-HR-Employee-Attrition.csv
/sql         → hr_queries.sql (view creation + 8 analysis queries)
/powerbi     → hr_attrition_dashboard.pbix

README.md    → this file
```

## Dashboard Pages
1. **Workforce Overview** — KPI cards (Total Employees, Employees Left, Attrition Rate, Avg Monthly Income, Avg Tenure) with department/gender/marital status slicers and an attrition-by-department chart
2. **Attrition Drivers** — Overtime, Job Satisfaction, Tenure Bucket, and Work-Life Balance vs. attrition rate
3. **Compensation & Roles** — Income comparison (left vs. stayed) by job role, attrition rate by job role, and attrition vs. distance from home
4. **Recommendations** — Color-coded (red/yellow/green) risk table by department and job role, plus written findings

## How to Reproduce
1. Load `WA_Fn-UseC_-HR-Employee-Attrition.csv` into a SQL database (SQLite/PostgreSQL)
2. Run the queries in `hr_queries.sql` to reproduce the aggregated analysis
3. Open `hr_attrition_dashboard.pbix` in Power BI Desktop, or rebuild the model by importing the raw CSV and applying the DAX measures documented alongside the queries

## Next Steps (if extended further)
- Build a simple logistic regression or decision tree to rank attrition drivers by statistical importance, rather than relying on univariate cuts
- Model the estimated cost of attrition (replacement cost per role) to prioritize recommendations by financial impact
- Segment analysis by manager, since manager quality is a well-documented attrition driver not captured directly in this dataset
