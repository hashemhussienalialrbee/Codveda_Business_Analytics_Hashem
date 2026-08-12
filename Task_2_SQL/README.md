# Codveda Business Analytics Internship

## Intern
**Hashem Alrabee**

## Task 2 – SQL Business Analytics

This task analyzes customer churn data using SQL Server. The work uses multiple related tables and demonstrates joins, aggregation, churn analysis, customer segmentation, indexing, and execution-plan review.

### Database Tables
- `Customers` – customer information, state, account length, and churn status.
- `Customer_Plans` – international plan, voice mail plan, and voicemail messages.
- `Customer_Usage` – daily, evening, night, international usage and customer service calls.
- `Customer_Segments` – customer risk segmentation used for retention analysis.

### SQL Analysis Completed

1. **Multi-table Customer Join**
   - Joined `Customers`, `Customer_Plans`, and `Customer_Usage` using `CustomerID`.
   - Produced a combined customer-level dataset.

2. **International Plan Churn Analysis**
   - Compared total customers, churned customers, and churn rate for customers with and without an international plan.
   - Result:
     - International Plan: **43.70% churn rate**
     - No International Plan: **11.27% churn rate**

3. **Customer Service Calls Analysis**
   - Calculated churn rate by number of customer service calls.
   - Higher service-call frequency is associated with substantially higher churn rates in the analyzed dataset.

4. **State-Level Churn Analysis**
   - Calculated total customers, churned customers, and churn rate by state.
   - Results were ordered by churn rate.

5. **Risk Segmentation**
   - Analyzed churn by customer risk segment.
   - Results:
     - High Risk: **68.18%**
     - Medium Risk: **51.06%**
     - Lower Risk: **11.28%**

6. **Indexing**
   - Created indexes on `CustomerID` in:
     - `Customer_Plans`
     - `Customer_Usage`
   - Verified the indexes using SQL Server system catalog views.

7. **Execution Plan & Performance Review**
   - Reviewed the execution plan for the multi-table join.
   - Captured SQL Server execution statistics and logical reads before/after indexing.
   - The query returned **2,666 rows**.

### Files Included

- `Codveda_Business_Analytics_SQL.sql` – SQL scripts for the analysis.
- `SQL_International_Plan` – International plan churn analysis result.
- `SQL_Service_Calls` – Customer service calls churn analysis result.
- `SQL_Risk_Segmentation` – Risk segment churn analysis result.
- `SQL_Indexes` – Index creation and index verification.
- `SQL_Execution_Plan` – SQL Server execution plan evidence.

### Key Business Insight

The analysis indicates that customer churn is substantially higher among customers with an international plan, customers with frequent service calls, and higher-risk customer segments. These findings can support targeted customer-retention strategies.

### Data Limitation

The findings represent associations observed in the analyzed dataset and should not be interpreted as proof of causation. Further analysis would be required to identify the underlying causes of customer churn.
