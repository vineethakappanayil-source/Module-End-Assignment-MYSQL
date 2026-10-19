E-Commerce Customer Churn Analysis

## Project Overview

This project analyzes customer churn in an e-commerce business. It uses customer tenure, complaints, satisfaction, payment preferences, order behavior, app usage, and cashback data to explore patterns associated with customer attrition and identify opportunities to improve retention.

## Dataset

The dataset contains customer-level information, including:

- Churn and complaint indicators
- Tenure, gender, and marital status
- Preferred login device, payment method, and order category
- Warehouse-to-home distance
- App usage and registered devices
- Satisfaction scores, coupons, order counts, and cashback

The provided SQL dataset file creates the `ecomm` database and loads the `customer_churn` table.

## Tools

- MySQL 8.0 or later
- MySQL Workbench or another MySQL client

## How to Use

1. Open the provided customer churn SQL dataset file in MySQL Workbench.
2. Run it to create the database and load the customer records.
3. Complete the data cleaning and transformation steps described below.
4. Perform the analysis questions and record the query results for the assignment report.

> **Note:** The provided setup script drops and recreates the `ecomm` database. Running it again replaces the current database and its data.

## Data Cleaning

- Fill missing values with rounded column means for warehouse distance, app hours, order amount hike, and days since the last order.
- Fill missing tenure, coupon usage, and order count values using each column's mode.
- Remove rows where warehouse-to-home distance is greater than 100.
- Standardize login device and order category labels so that phone and mobile entries use “Mobile Phone.”
- Standardize payment method labels, replacing “COD” with “Cash on Delivery” and “CC” with “Credit Card.”

## Data Transformation

- Rename the preferred order category and app hours columns to correct and consistent names.
- Add a complaint status field with “Yes” or “No” values.
- Add a customer status field with “Churned” or “Active” values.
- Remove the original numeric churn and complaint indicator columns after creating the readable status fields.

## Analysis Objectives

The project explores:

1. The number of churned and active customers.
2. Average tenure and total cashback among churned customers.
3. The share of churned customers who complained.
4. Which city tier has the most churned customers ordering Laptop & Accessory products.
5. The most common payment method among active customers.
6. Total order amount increase for single customers preferring mobile phone orders.
7. Average registered devices among customers paying with UPI.
8. The city tier with the most customers overall.
9. Coupon usage totals by gender.
10. Customer counts and maximum app hours for each order category.
11. Total orders for credit-card customers with the highest satisfaction score.
12. Average satisfaction score among customers who complained.
13. Order categories chosen by customers who used more than five coupons.
14. The three order categories with the highest average cashback.
15. Payment methods associated with groups averaging 10 months of tenure and more than 500 total orders.
16. Churn status across four warehouse distance groups: very close (up to 5 km), close (up to 10 km), moderate (up to 15 km), and far (over 15 km).
17. Order details for married customers in City Tier 1 whose order count is above the overall customer average.
18. Return details joined with customer information for customers who both churned and complained.

## Customer Returns

The assignment provides eight return records, each with a return ID, customer ID, return date, and refund amount. These records are stored in a separate `customer_returns` table and joined to customer information to identify returns associated with churned customers who complained. Some return customer IDs may not be present in the supplied customer dataset.

## Suggested Report Contents

For each analysis objective, include a brief description of the question, the result obtained from MySQL, and a short interpretation. Conclude with key churn patterns and practical retention opportunities supported by the analysis.
