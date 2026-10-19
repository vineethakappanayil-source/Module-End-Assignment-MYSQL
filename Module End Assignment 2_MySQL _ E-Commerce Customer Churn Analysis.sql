USE ecomm;
select * from customer_churn;
-- Data Cleaning: 
-- Handling Missing Values and Outliers:
/*  Impute mean  for the following columns, and round off to the nearest integer if 
required: WarehouseToHome, HourSpendOnApp, OrderAmountHikeFromlastYear, 
DaySinceLastOrder.
*/
SET SQL_SAFE_UPDATES = 0;
UPDATE customer_churn
SET WarehouseToHome = (
    SELECT avg_value
    FROM (
        SELECT ROUND(AVG(WarehouseToHome)) AS avg_value
        FROM customer_churn
    ) AS temp
)
WHERE WarehouseToHome IS NULL;

UPDATE customer_churn
SET HourSpendOnApp = (
    SELECT avg_value
    FROM (
        SELECT ROUND(AVG(HourSpendOnApp)) AS avg_value
        FROM customer_churn
    ) AS temp
)
WHERE HourSpendOnApp IS NULL;
UPDATE customer_churn
SET OrderAmountHikeFromlastYear = (
    SELECT avg_value
    FROM (
        SELECT ROUND(AVG(OrderAmountHikeFromlastYear)) AS avg_value
        FROM customer_churn
    ) AS temp
)
WHERE OrderAmountHikeFromlastYear IS NULL;
UPDATE customer_churn
SET DaySinceLastOrder = (
    SELECT avg_value
    FROM (
        SELECT ROUND(AVG(DaySinceLastOrder)) AS avg_value
        FROM customer_churn
    ) AS temp
)
WHERE DaySinceLastOrder IS NULL;
SELECT
    SUM(WarehouseToHome IS NULL) AS WarehouseToHome_Null,
    SUM(HourSpendOnApp IS NULL) AS HourSpendOnApp_Null,
    SUM(OrderAmountHikeFromlastYear IS NULL) AS OrderAmountHike_Null,
    SUM(DaySinceLastOrder IS NULL) AS DaySinceLastOrder_Null
FROM customer_churn;
--  Impute mode for the following columns: Tenure, CouponUsed, OrderCount.
-- Impute mode for tenure
UPDATE customer_churn
SET Tenure = (
    SELECT mode_value
    FROM (
        SELECT Tenure AS mode_value
        FROM customer_churn
        WHERE Tenure IS NOT NULL
        GROUP BY Tenure
        ORDER BY COUNT(*) DESC, Tenure ASC
        LIMIT 1
    ) AS temp
)
WHERE Tenure IS NULL;

-- Impute mode for CouponUsed

UPDATE customer_churn
SET CouponUsed = (
    SELECT mode_value
    FROM (
        SELECT CouponUsed AS mode_value
        FROM customer_churn
        WHERE CouponUsed IS NOT NULL
        GROUP BY CouponUsed
        ORDER BY COUNT(*) DESC, CouponUsed ASC
        LIMIT 1
    ) AS temp
)
WHERE CouponUsed IS NULL;

-- Impute mode for OrderCount

UPDATE customer_churn
SET OrderCount = (
    SELECT mode_value
    FROM (
        SELECT OrderCount AS mode_value
        FROM customer_churn
        WHERE OrderCount IS NOT NULL
        GROUP BY OrderCount
        ORDER BY COUNT(*) DESC, OrderCount ASC
        LIMIT 1
    ) AS temp
)
WHERE OrderCount IS NULL;

-- Verify missing values
SELECT
    SUM(Tenure IS NULL) AS Tenure_Null,
    SUM(CouponUsed IS NULL) AS CouponUsed_Null,
    SUM(OrderCount IS NULL) AS OrderCount_Null
FROM customer_churn;

-- Handle outliers in the 'WarehouseToHome' column by deleting rows where the values are greater than 100.

DELETE FROM customer_churn
WHERE WarehouseToHome > 100;
SELECT *
FROM customer_churn
WHERE WarehouseToHome > 100;

-- Dealing with Inconsistencies: 
-- Replace occurrences of “Phone” in the 'PreferredLoginDevice' column and “Mobile” in the 'PreferedOrderCat' column with “Mobile Phone” to ensure uniformity.
-- Replace Phone with Mobile Phone in PreferredLoginDevice
UPDATE customer_churn
SET PreferredLoginDevice = 'Mobile Phone'
WHERE PreferredLoginDevice = 'Phone';

-- Replace Mobile with Mobile Phone in PreferedOrderCat
UPDATE customer_churn
SET PreferedOrderCat = 'Mobile Phone'
WHERE PreferedOrderCat = 'Mobile';

SELECT DISTINCT PreferredLoginDevice
FROM customer_churn;

SELECT DISTINCT PreferedOrderCat
FROM customer_churn;

--  Standardize payment mode values: Replace "COD" with "Cash on Delivery" and "CC" with "Credit Card" in the PreferredPaymentMode column. 

UPDATE customer_churn
SET PreferredPaymentMode = 'Cash on Delivery'
WHERE PreferredPaymentMode = 'COD';

UPDATE customer_churn
SET PreferredPaymentMode = 'Credit Card'
WHERE PreferredPaymentMode = 'CC';

SELECT DISTINCT PreferredPaymentMode
FROM customer_churn;

-- Data Transformation:  
-- Column Renaming: 
-- Rename the column "PreferedOrderCat" to "PreferredOrderCat". 

ALTER TABLE customer_churn
RENAME COLUMN PreferedOrderCat TO PreferredOrderCat;
 -- Rename the column "HourSpendOnApp" to "HoursSpentOnApp". 
 alter table customer_churn
 rename column HourSpendOnApp to HoursSpentOnApp;
 
-- Creating New Columns: 

--  Create a new column named ‘ComplaintReceived’ with values "Yes" if the corresponding value in the ‘Complain’ is 1, and "No" otherwise.
-- Create a new column named 'ChurnStatus'. Set its value to “Churned” if the corresponding value in the 'Churn' column is 1, else assign “Active”.
ALTER TABLE customer_churn
ADD COLUMN ComplaintReceived VARCHAR(3),
ADD COLUMN ChurnStatus VARCHAR(10);
UPDATE customer_churn
SET ComplaintReceived = 
    CASE
        WHEN Complain = 1 THEN 'Yes'
        ELSE 'No'
    END;
    UPDATE customer_churn
SET ChurnStatus =
    CASE
        WHEN Churn = 1 THEN 'Churned'
        ELSE 'Active'
    END;
    
    SELECT Complain, ComplaintReceived, Churn, ChurnStatus
FROM customer_churn;


-- Column Dropping: 
-- Drop the columns "Churn" and "Complain" from the table.
ALTER TABLE customer_churn
DROP COLUMN Churn,
DROP COLUMN Complain;

DESCRIBE customer_churn;
-- Data Exploration and Analysis:  
-- Retrieve the count of churned and active customers from the dataset. 
SELECT 
    ChurnStatus,
    COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY ChurnStatus;


--  Display the average tenure and total cashback amount of customers who churned. 
SELECT
    AVG(Tenure) AS AverageTenure,
    SUM(CashbackAmount) AS TotalCashbackAmount
FROM customer_churn
WHERE ChurnStatus = 'Churned';
-- Determine the percentage of churned customers who complained. 
SELECT ROUND(100 * SUM(ComplaintReceived = 'Yes') / COUNT(*), 2) AS percentage_of_ChurnedWhoComplained
FROM customer_churn
WHERE ChurnStatus = 'Churned';

--  Identify the city tier with the highest number of churned customers whose preferred order category is Laptop & Accessory. 
SELECT CityTier, COUNT(*) AS ChurnedCustomers
FROM customer_churn
WHERE ChurnStatus = 'Churned' AND PreferredOrderCat = 'Laptop & Accessory'
GROUP BY CityTier
ORDER BY ChurnedCustomers DESC
LIMIT 1;
--  Identify the most preferred payment mode among active customers.
SELECT
    PreferredPaymentMode,
    COUNT(*) AS CustomerCount
FROM customer_churn
WHERE ChurnStatus = 'Active'
GROUP BY PreferredPaymentMode
ORDER BY CustomerCount DESC
LIMIT 1;
-- Calculate the total order amount hike from last year for customers who are single and prefer mobile phones for ordering.
	SELECT SUM(OrderAmountHikeFromlastYear) AS TotalOrderAmountHike
FROM customer_churn
WHERE MaritalStatus = 'Single' 
AND PreferredOrderCat = 'Mobile Phone';
-- Find the average number of devices registered among customers who used UPI as their preferred payment mode.
SELECT
    AVG(NumberOfDeviceRegistered) AS AverageDevicesRegistered
FROM customer_churn
WHERE PreferredPaymentMode = 'UPI';

-- Determine the city tier with the highest number of customers. 
SELECT
    CityTier,
    COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY CityTier
ORDER BY CustomerCount DESC
LIMIT 1;
--  Identify the gender that utilized the highest number of coupons

SELECT Gender, SUM(CouponUsed) AS TotalCoupons
FROM customer_churn
GROUP BY Gender
ORDER BY TotalCoupons DESC
LIMIT 1;
-- List the number of customers and the maximum hours spent on the app in each preferred order category.
SELECT PreferredOrderCat,
       COUNT(*)             AS Customers,
       MAX(HoursSpentOnApp) AS MaxHoursSpentOnApp
FROM customer_churn
GROUP BY PreferredOrderCat;
-- Calculate the total order count for customers who prefer using credit cards and have the maximum satisfaction score.
SELECT SUM(OrderCount) AS TotalOrderCount
FROM customer_churn
WHERE PreferredPaymentMode = 'Credit Card'
  AND SatisfactionScore = (SELECT MAX(SatisfactionScore) FROM customer_churn);
  -- What is the average satisfaction score of customers who have complained?
  SELECT ROUND(AVG(SatisfactionScore), 2) AS AvgSatisfaction
FROM customer_churn
WHERE ComplaintReceived = 'Yes';
-- List the preferred order category among customers who used more than 5 coupons. 
SELECT DISTINCT PreferredOrderCat
FROM customer_churn
WHERE CouponUsed > 5;
-- List the top 3 preferred order categories with the highest average cashback amount.
SELECT PreferredOrderCat, ROUND(AVG(CashbackAmount), 2) AS AvgCashback
FROM customer_churn
GROUP BY PreferredOrderCat
ORDER BY AvgCashback DESC
LIMIT 3;
-- Find the preferred payment modes of customers whose average tenure is 10 months and have placed more than 500 orders.
--    (total orders per payment mode > 500; average tenure rounded to a whole month, because no mode averages exactly 10.00)
SELECT PreferredPaymentMode,
       ROUND(AVG(Tenure), 2) AS AvgTenure,
       SUM(OrderCount)       AS TotalOrders
FROM customer_churn
GROUP BY PreferredPaymentMode
HAVING ROUND(AVG(Tenure)) = 10 AND SUM(OrderCount) > 500;
/*Categorize customers based on their distance from the warehouse to home such 
as 'Very Close Distance' for distances <=5km, 'Close Distance' for <=10km, 
'Moderate Distance' for <=15km, and 'Far Distance' for >15km. Then, display the 
churn status breakdown for each distance category. 
*/
SELECT CASE
         WHEN WarehouseToHome <= 5  THEN 'Very Close Distance'
         WHEN WarehouseToHome <= 10 THEN 'Close Distance'
         WHEN WarehouseToHome <= 15 THEN 'Moderate Distance'
         ELSE 'Far Distance'
       END AS DistanceCategory,
       ChurnStatus,
       COUNT(*) AS Customers
FROM customer_churn
GROUP BY DistanceCategory, ChurnStatus
ORDER BY FIELD(DistanceCategory, 'Very Close Distance', 'Close Distance',
                                 'Moderate Distance', 'Far Distance'),
         ChurnStatus;
/* List the customer’s order details who are married, live in City Tier-1, and their 
order counts are more than the average number of orders placed by all 
customers. 
*/
SELECT CustomerID, OrderCount, OrderAmountHikeFromlastYear, CouponUsed,
       DaySinceLastOrder, CashbackAmount, PreferredOrderCat
FROM customer_churn
WHERE MaritalStatus = 'Married'
  AND CityTier = 1
  AND OrderCount > (SELECT AVG(OrderCount) FROM customer_churn);
  -- Create a ‘customer_returns’ table in the ‘ecomm’ database and insert the following data: 
  CREATE TABLE customer_returns (
    ReturnID     INT PRIMARY KEY,
    CustomerID   INT,
    ReturnDate   DATE,
    RefundAmount INT
);
INSERT INTO customer_returns (ReturnID, CustomerID, ReturnDate, RefundAmount) VALUES
(1001, 50022, '2023-01-01', 2130),
(1002, 50316, '2023-01-23', 2000),
(1003, 51099, '2023-02-14', 2290),
(1004, 52321, '2023-03-08', 2510),
(1005, 52928, '2023-03-20', 3000),
(1006, 53749, '2023-04-17', 1740),
(1007, 54206, '2023-04-21', 3250),
(1008, 54838, '2023-04-30', 1990);
-- Display the return details along with the customer details of those who have churned and have made complaints. 
SELECT r.ReturnID, r.ReturnDate, r.RefundAmount, c.*
FROM customer_returns r
JOIN customer_churn  c ON c.CustomerID = r.CustomerID
WHERE c.ChurnStatus = 'Churned'
  AND c.ComplaintReceived = 'Yes';
 
SET SQL_SAFE_UPDATES = 1;