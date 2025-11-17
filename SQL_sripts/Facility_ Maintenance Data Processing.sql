/*
Facility Maintenance Data Processing & Exploratory SQL Analysis
Author: Dr. Mohammed Soliman
Tools: PostgreSQL | SQL Queries

This script performs:
✅ Table Creation & Data Import
✅ Data Cleaning (whitespace removal, text normalization)
✅ Exploratory Data Analysis (distinct values, descriptive stats)
✅ Cost & Failure Rate Analytics
✅ Equipment & Location Performance Metrics
✅ Monthly Request Volume Analysis
*/

-- Drop table if exists
DROP TABLE IF EXISTS Facility;

-- Create Facility table
CREATE TABLE Facility (
    operation_id SERIAL PRIMARY KEY,
    maintenance_type TEXT,
    request_date DATE,
    completion_date DATE,
    duration INTEGER,
    maintenance_cost NUMERIC(12,2),
    location TEXT,
    request_status TEXT,
    equipment TEXT,
    employee_count INTEGER,
    energy_consumption NUMERIC(10,2),
    failure_rate NUMERIC(6,2),
    importance_level TEXT,
    notes TEXT
);

-- Set date style
SHOW datestyle;
SET datestyle = 'DMY';

-- Import data
COPY Facility
FROM 'C:\SQL Data\facility.csv'
DELIMITER ';'
CSV HEADER;

-- Basic preview
SELECT COUNT(*) FROM Facility;
SELECT * FROM Facility;

-- Normalize text columns (trim + remove extra spaces)
DO $$
DECLARE s TEXT;
BEGIN
    SELECT 'UPDATE public.Facility SET ' ||
           STRING_AGG(
               FORMAT(
                   '%I = regexp_replace(btrim(%I), ''\s+'', '' '', ''g'')',
                   column_name, column_name
               ), ', '
           )
    INTO s
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'facility'
      AND data_type    = 'text';

    IF s IS NOT NULL THEN EXECUTE s; END IF;
END $$;

-- Distinct categorical values
SELECT DISTINCT maintenance_type FROM Facility;
SELECT DISTINCT location FROM Facility;
SELECT DISTINCT equipment FROM Facility;
SELECT DISTINCT employee_count FROM Facility;
SELECT DISTINCT request_status FROM Facility;

-- Maintenance cost statistics
SELECT 
    MIN(maintenance_cost) AS min_cost,
    MAX(maintenance_cost) AS max_cost,
    AVG(maintenance_cost) AS avg_cost,
    SUM(maintenance_cost) AS total_cost
FROM Facility;

-- Failure rate statistics
SELECT 
    MIN(failure_rate) AS min_failure_rate,
    MAX(failure_rate) AS max_failure_rate,
    AVG(failure_rate) AS avg_failure_rate,
    SUM(failure_rate) AS total_failure_rate
FROM Facility;

-- Failure frequency per equipment
SELECT 
    equipment,
    COUNT(*) AS failure_count
FROM Facility
GROUP BY equipment
ORDER BY failure_count DESC
LIMIT 5;

-- Average energy consumption per location
SELECT 
    location,
    AVG(energy_consumption) AS avg_energy_consumption
FROM Facility
GROUP BY location;

-- Average maintenance duration by maintenance type
SELECT 
    maintenance_type,
    AVG(duration) AS avg_duration_days
FROM Facility
GROUP BY maintenance_type
ORDER BY avg_duration_days DESC;

-- Monthly request volume
SELECT 
    DATE_TRUNC('month', request_date) AS month,
    COUNT(*) AS total_requests
FROM Facility
GROUP BY month
ORDER BY month;

-- Maintenance duration by location
SELECT 
    location,
    AVG(duration) AS avg_duration_days
FROM Facility
GROUP BY location;

-- Final preview
SELECT * FROM Facility;
