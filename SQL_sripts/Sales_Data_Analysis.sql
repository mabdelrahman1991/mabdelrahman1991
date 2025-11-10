/*
Sales Data Processing & Exploratory SQL Analysis
Author: Dr. Mohammed Soliman
Tools: PostgreSQL | SQL Queries

This script performs:
✅ Table Creation & Data Import
✅ Data Cleaning (remove duplicates, handle nulls)
✅ Descriptive Statistics (min, max, average, totals)
✅ Revenue & Quantity Analysis by Product & City
✅ Monthly & Daily Sales Aggregation
✅ Pareto Analysis (Top revenue-driving products)
✅ Data Export Preparation
*/



-- Create sales data table
CREATE TABLE sales_data (
    id INTEGER,
    product TEXT,
    revenue NUMERIC(12,2),
    sale_date TIMESTAMP,
    quantity INTEGER,
    category TEXT,
    city TEXT
);

-- Set date format
SET datestyle = 'DMY';

-- Import CSV data
COPY sales_data(id, product, revenue, sale_date, quantity, category, city)
FROM 'C:\\SQL DATA\\sales data.csv'
DELIMITER ';' 
CSV HEADER;

-- View data
SELECT * FROM sales_data;

-- Row count
SELECT COUNT(*) FROM sales_data;

-- Check column info
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'sales_data';

-- Distinct products
SELECT DISTINCT product FROM sales_data;

-- General revenue statistics
SELECT 
    MIN(revenue) AS min_revenue,
    MAX(revenue) AS max_revenue,
    AVG(revenue) AS avg_revenue,
    SUM(revenue) AS total_revenue
FROM sales_data;

-- Average revenue per product
SELECT 
    product,
    TO_CHAR(AVG(revenue), 'FM999,999,999,999.00') AS avg_revenue
FROM sales_data
GROUP BY product;

-- Top products by quantity sold
SELECT product, SUM(quantity) AS total_quantity
FROM sales_data
GROUP BY product
ORDER BY total_quantity DESC;

-- Top products by revenue
SELECT product, SUM(revenue) AS total_revenue
FROM sales_data
GROUP BY product
ORDER BY total_revenue DESC;

-- Top cities by revenue
SELECT city, SUM(revenue) AS total_revenue
FROM sales_data
GROUP BY city
ORDER BY total_revenue DESC;

-- City-wise quantity per product (similar to SUMIFS logic)
SELECT city, product, SUM(quantity) AS total_quantity
FROM sales_data
GROUP BY city, product
ORDER BY city, total_quantity DESC;

-- City-wise revenue per product
SELECT city, product, SUM(revenue) AS total_revenue
FROM sales_data
GROUP BY city, product
ORDER BY city, total_revenue DESC;

-- Monthly total revenue
SELECT DATE_TRUNC('month', sale_date) AS month, 
       SUM(revenue) AS total_revenue
FROM sales_data
GROUP BY month
ORDER BY total_revenue DESC;

-- Daily revenue
SELECT sale_date, SUM(revenue) AS daily_revenue
FROM sales_data
GROUP BY sale_date
ORDER BY sale_date DESC;

-- Days with revenue above threshold
SELECT sale_date, SUM(revenue) AS total_revenue
FROM sales_data
GROUP BY sale_date
HAVING SUM(revenue) > 2000000
ORDER BY total_revenue DESC;

-- Remove duplicates by key fields
DELETE FROM sales_data
WHERE ctid NOT IN (
    SELECT MIN(ctid) FROM sales_data 
    GROUP BY id, product, quantity, category, revenue, sale_date, city
);

-- Delete rows with NULL revenue
DELETE FROM sales_data WHERE revenue IS NULL;

-- Fill missing revenue with average value
UPDATE sales_data
SET revenue = (SELECT AVG(revenue) FROM sales_data)
WHERE revenue IS NULL;

-- Revenue % by month
SELECT DATE_TRUNC('month', sale_date) AS month, 
       SUM(revenue) / (SELECT SUM(revenue) FROM sales_data) AS revenue_percentage
FROM sales_data
GROUP BY month
ORDER BY revenue_percentage DESC;

-- Quantity % by month
SELECT DATE_TRUNC('month', sale_date) AS month, 
       SUM(quantity)*100.0/(SELECT SUM(quantity) FROM sales_data) AS quantity_percentage
FROM sales_data
GROUP BY month
ORDER BY quantity_percentage DESC;

-- Revenue % by product
SELECT product, 
       SUM(revenue) / (SELECT SUM(revenue) FROM sales_data) AS revenue_percentage
FROM sales_data
GROUP BY product
ORDER BY revenue_percentage DESC;

-- Highest month by quantity
SELECT DATE_TRUNC('month', sale_date) AS month, 
       SUM(quantity) AS total_quantity
FROM sales_data
GROUP BY month
ORDER BY total_quantity DESC
LIMIT 1;

-- Top 2 products by quantity
SELECT product, SUM(quantity) AS total_quantity
FROM sales_data
GROUP BY product
ORDER BY total_quantity DESC
LIMIT 2;

-- Least 2 products by quantity
SELECT product, SUM(quantity) AS total_quantity
FROM sales_data
GROUP BY product
ORDER BY total_quantity ASC
LIMIT 2;

-- Pareto: products contributing most to revenue (80/20)
SELECT product, 
       SUM(revenue) AS total_revenue,
       SUM(revenue) / (SELECT SUM(revenue) FROM sales_data) AS revenue_percentage
FROM sales_data
GROUP BY product
ORDER BY total_revenue DESC;

-- Cumulative sales by date (quantity)
SELECT sale_date, product,
       SUM(quantity) OVER (PARTITION BY product ORDER BY sale_date) AS cumulative_quantity
FROM sales_data
ORDER BY product, sale_date;

-- Cumulative revenue by date
SELECT sale_date, product,
       SUM(revenue) OVER (PARTITION BY product ORDER BY sale_date) AS cumulative_revenue
FROM sales_data
ORDER BY product, sale_date;
