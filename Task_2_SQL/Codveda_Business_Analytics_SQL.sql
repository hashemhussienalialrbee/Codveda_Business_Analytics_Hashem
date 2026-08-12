/*
=========================================================
Codveda Technologies - Business Analytics Internship
Task 2: SQL for Business Analytics
Project: Customer Churn & Retention Analytics
Author: Hashem Hussein Al-Rabiee
=========================================================
*/

USE Codveda_Business_Analytics;
GO

/* 1. DATA VALIDATION */
SELECT COUNT(*) AS Total_Customers
FROM dbo.[churn-bigml-80];
GO

SELECT TOP 10 *
FROM dbo.[churn-bigml-80]
ORDER BY CustomerID;
GO

/* 2. DATA MODEL / RELATED TABLES */
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    State NVARCHAR(50),
    Account_length TINYINT,
    Churn BIT
);

INSERT INTO Customers
SELECT CustomerID, State, Account_length, Churn
FROM dbo.[churn-bigml-80];
GO

CREATE TABLE Customer_Plans (
    CustomerID INT PRIMARY KEY,
    International_plan BIT,
    Voice_mail_plan BIT,
    Number_vmail_messages TINYINT
);

INSERT INTO Customer_Plans
SELECT CustomerID, International_plan, Voice_mail_plan, Number_vmail_messages
FROM dbo.[churn-bigml-80];
GO

CREATE TABLE Customer_Usage (
    CustomerID INT PRIMARY KEY,
    Total_day_minutes FLOAT,
    Total_day_calls TINYINT,
    Total_day_charge FLOAT,
    Total_eve_minutes FLOAT,
    Total_eve_calls TINYINT,
    Total_eve_charge FLOAT,
    Total_night_minutes FLOAT,
    Total_night_calls TINYINT,
    Total_night_charge FLOAT,
    Total_intl_minutes FLOAT,
    Total_intl_calls TINYINT,
    Total_intl_charge FLOAT,
    Customer_service_calls TINYINT
);

INSERT INTO Customer_Usage
SELECT
    CustomerID, Total_day_minutes, Total_day_calls, Total_day_charge,
    Total_eve_minutes, Total_eve_calls, Total_eve_charge,
    Total_night_minutes, Total_night_calls, Total_night_charge,
    Total_intl_minutes, Total_intl_calls, Total_intl_charge,
    Customer_service_calls
FROM dbo.[churn-bigml-80];
GO

SELECT
    (SELECT COUNT(*) FROM Customers) AS Customers,
    (SELECT COUNT(*) FROM Customer_Plans) AS Plans,
    (SELECT COUNT(*) FROM Customer_Usage) AS Usage_Data;
GO

/* 3. BASIC BUSINESS METRICS */
SELECT
    COUNT(*) AS Total_Customers,
    SUM(CAST(Churn AS INT)) AS Churned_Customers,
    COUNT(*) - SUM(CAST(Churn AS INT)) AS Active_Customers,
    CAST(SUM(CAST(Churn AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Churn_Rate
FROM Customers;
GO

SELECT AVG(CAST(Account_length AS DECIMAL(10,2))) AS Avg_Account_Length
FROM Customers;
GO

SELECT AVG(CAST(Customer_service_calls AS DECIMAL(10,2))) AS Avg_Customer_Service_Calls
FROM Customer_Usage;
GO

/* 4. CHURN BY INTERNATIONAL PLAN */
SELECT
    CASE WHEN p.International_plan = 1 THEN 'Yes' ELSE 'No' END AS International_Plan,
    COUNT(*) AS Total_Customers,
    SUM(CAST(c.Churn AS INT)) AS Churned_Customers,
    CAST(SUM(CAST(c.Churn AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Churn_Rate
FROM Customers AS c
INNER JOIN Customer_Plans AS p ON c.CustomerID = p.CustomerID
GROUP BY p.International_plan
ORDER BY Churn_Rate DESC;
GO

/* 5. CHURN BY CUSTOMER SERVICE CALLS */
SELECT
    u.Customer_service_calls,
    COUNT(*) AS Total_Customers,
    SUM(CAST(c.Churn AS INT)) AS Churned_Customers,
    CAST(SUM(CAST(c.Churn AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Churn_Rate
FROM Customers AS c
INNER JOIN Customer_Usage AS u ON c.CustomerID = u.CustomerID
GROUP BY u.Customer_service_calls
ORDER BY u.Customer_service_calls;
GO

/* 6. CHURN BY STATE */
SELECT
    c.State,
    COUNT(*) AS Total_Customers,
    SUM(CAST(c.Churn AS INT)) AS Churned_Customers,
    CAST(SUM(CAST(c.Churn AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Churn_Rate
FROM Customers AS c
GROUP BY c.State
ORDER BY Churn_Rate DESC;
GO

/* 7. THREE-TABLE JOIN */
SELECT
    c.CustomerID,
    c.State,
    c.Account_length,
    p.International_plan,
    p.Voice_mail_plan,
    u.Customer_service_calls,
    c.Churn
FROM Customers AS c
INNER JOIN Customer_Plans AS p ON c.CustomerID = p.CustomerID
INNER JOIN Customer_Usage AS u ON c.CustomerID = u.CustomerID;
GO

/* 8. ADVANCED SQL: CTE + CASE + JOIN + AGGREGATION */
WITH Customer_Segments AS
(
    SELECT
        c.CustomerID,
        p.International_plan,
        u.Customer_service_calls,
        c.Churn,
        CASE
            WHEN u.Customer_service_calls >= 4 AND p.International_plan = 1 THEN 'High Risk'
            WHEN u.Customer_service_calls >= 4 THEN 'Medium Risk'
            ELSE 'Lower Risk'
        END AS Risk_Segment
    FROM Customers AS c
    INNER JOIN Customer_Plans AS p ON c.CustomerID = p.CustomerID
    INNER JOIN Customer_Usage AS u ON c.CustomerID = u.CustomerID
)
SELECT
    Risk_Segment,
    COUNT(*) AS Total_Customers,
    SUM(CAST(Churn AS INT)) AS Churned_Customers,
    CAST(SUM(CAST(Churn AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Churn_Rate
FROM Customer_Segments
GROUP BY Risk_Segment
ORDER BY Churn_Rate DESC;
GO

/* 9. INDEXING FOR JOIN SUPPORT */
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_Customer_Plans_CustomerID'
      AND object_id = OBJECT_ID('dbo.Customer_Plans')
)
CREATE INDEX IX_Customer_Plans_CustomerID
ON dbo.Customer_Plans (CustomerID);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_Customer_Usage_CustomerID'
      AND object_id = OBJECT_ID('dbo.Customer_Usage')
)
CREATE INDEX IX_Customer_Usage_CustomerID
ON dbo.Customer_Usage (CustomerID);
GO

/* 10. VERIFY INDEXES */
SELECT
    t.name AS Table_Name,
    i.name AS Index_Name,
    c.name AS Column_Name
FROM sys.indexes AS i
INNER JOIN sys.index_columns AS ic
    ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns AS c
    ON ic.object_id = c.object_id AND ic.column_id = c.column_id
INNER JOIN sys.tables AS t
    ON i.object_id = t.object_id
WHERE t.name IN ('Customer_Plans', 'Customer_Usage')
ORDER BY t.name, i.name;
GO

/* 11. PERFORMANCE MEASUREMENT
   Run with Actual Execution Plan enabled (Ctrl + M). */
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
    c.CustomerID,
    c.State,
    c.Account_length,
    p.International_plan,
    p.Voice_mail_plan,
    u.Customer_service_calls,
    c.Churn
FROM Customers AS c
INNER JOIN Customer_Plans AS p ON c.CustomerID = p.CustomerID
INNER JOIN Customer_Usage AS u ON c.CustomerID = u.CustomerID;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

/*
Observed during analysis:
Rows returned = 2,666
Logical reads = 47 total
  Customers = 10
  Customer_Usage = 30
  Customer_Plans = 7
Physical reads = 0
CPU time = 0 ms
Elapsed time = 62 ms

Execution plan observation:
SQL Server selected clustered index scans and hash joins for this
relatively small dataset. This is reasonable because a full scan
can be cheaper than additional index lookups.
*/

/* 12. FINAL BUSINESS INSIGHT QUERIES */
SELECT
    CASE WHEN p.International_plan = 1 THEN 'Yes' ELSE 'No' END AS International_Plan,
    COUNT(*) AS Total_Customers,
    SUM(CAST(c.Churn AS INT)) AS Churned_Customers,
    CAST(SUM(CAST(c.Churn AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Churn_Rate
FROM Customers AS c
INNER JOIN Customer_Plans AS p ON c.CustomerID = p.CustomerID
GROUP BY p.International_plan
ORDER BY Churn_Rate DESC;
GO

SELECT
    u.Customer_service_calls,
    COUNT(*) AS Total_Customers,
    SUM(CAST(c.Churn AS INT)) AS Churned_Customers,
    CAST(SUM(CAST(c.Churn AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Churn_Rate
FROM Customers AS c
INNER JOIN Customer_Usage AS u ON c.CustomerID = u.CustomerID
GROUP BY u.Customer_service_calls
ORDER BY Churn_Rate DESC;
GO

/* END OF TASK 2 */
