/*  
===========================================================
Hotel Revenue Data Processing & SQL ETL Pipeline
Author: Dr. Mohammed Soliman
Tools: PostgreSQL | SQL | Data Cleaning | Data Integration

This script performs:
✔ Table creation & data loading  
✔ Data cleaning (handling NULL, fixing data types)  
✔ Numerical column validation  
✔ Joining market & meal reference tables  
✔ Building final unified dataset  
===========================================================
*/


/*----------------------------------------------------------
1) Drop table if exists (clean start)
----------------------------------------------------------*/
DROP TABLE IF EXISTS hotel_revenue;


/*----------------------------------------------------------
2) Create main hotel_revenue table
----------------------------------------------------------*/
CREATE TABLE hotel_revenue (
    hotel TEXT,
    is_canceled TEXT,
    lead_time NUMERIC,
    arrival_date_year NUMERIC,
    arrival_date_month TEXT,
    arrival_date_week_number NUMERIC,
    arrival_date_day_of_month NUMERIC,
    stays_in_weekend_nights NUMERIC,
    stays_in_week_nights NUMERIC,
    adults NUMERIC,
    children TEXT,
    babies NUMERIC,
    meal TEXT,
    country TEXT,
    market_segment TEXT,
    distribution_channel TEXT,
    is_repeated_guest NUMERIC,
    previous_cancellations NUMERIC,
    previous_bookings_not_canceled NUMERIC,
    reserved_room_type TEXT,
    assigned_room_type TEXT,
    booking_changes NUMERIC,
    deposit_type TEXT,
    agent TEXT,
    company TEXT,
    days_in_waiting_list NUMERIC,
    customer_type TEXT,
    adr FLOAT,
    required_car_parking_spaces NUMERIC,
    total_of_special_requests NUMERIC,
    reservation_status TEXT,
    reservation_status_date DATE
);


/*----------------------------------------------------------
3) Load CSV data
----------------------------------------------------------*/
COPY hotel_revenue
FROM 'C:/SQL DATA/hotel_revenue2018.csv'
DELIMITER ','  
CSV HEADER;

COPY hotel_revenue
FROM 'C:/SQL DATA/hotel_revenue2019.csv'
DELIMITER ','  
CSV HEADER;

COPY hotel_revenue
FROM 'C:/SQL DATA/hotel_revenue2020.csv'
DELIMITER ','  
CSV HEADER;


/*----------------------------------------------------------
4) Detect invalid numeric values + clean non-numeric values
Convert textual numbers into real INT/NUMERIC
----------------------------------------------------------*/
DO $$
DECLARE
    col RECORD;
    v_table TEXT := 'hotel_revenue';
    v_int_cols TEXT[] := ARRAY['is_canceled', 'is_repeated_guest', 'children', 'babies'];
    v_numeric_cols TEXT[] := ARRAY['lead_time', 'arrival_date_year', 'arrival_date_week_number',
                                    'arrival_date_day_of_month', 'stays_in_weekend_nights',
                                    'stays_in_week_nights', 'adults', 'previous_cancellations',
                                    'previous_bookings_not_canceled', 'booking_changes',
                                    'days_in_waiting_list', 'adr', 'required_car_parking_spaces',
                                    'total_of_special_requests'];
BEGIN
    -- Clean and convert INT columns
    FOREACH col IN ARRAY v_int_cols
    LOOP
        EXECUTE format('UPDATE %I SET %I = NULL WHERE %I !~ ''^\d+$'';', v_table, col, col);
        EXECUTE format('ALTER TABLE %I ALTER COLUMN %I TYPE INT USING %I::int;', v_table, col, col);
    END LOOP;

    -- Clean and convert NUMERIC columns
    FOREACH col IN ARRAY v_numeric_cols
    LOOP
        EXECUTE format('UPDATE %I SET %I = NULL WHERE %I !~ ''^\d+(\.\d+)?$'';', v_table, col, col);
        EXECUTE format('ALTER TABLE %I ALTER COLUMN %I TYPE NUMERIC USING %I::numeric;', v_table, col, col);
    END LOOP;
END $$;


/*----------------------------------------------------------
5) Create market_segment lookup table
----------------------------------------------------------*/
DROP TABLE IF EXISTS hotel_revenue_market_segment;

CREATE TABLE hotel_revenue_market_segment (
    discount FLOAT,
    market_segment TEXT
);

COPY hotel_revenue_market_segment
FROM 'C:/SQL DATA/hotel_revenue_market_segment.csv'
DELIMITER ','
CSV HEADER;


/*----------------------------------------------------------
6) Create meal_cost lookup table
----------------------------------------------------------*/
DROP TABLE IF EXISTS hotel_revenue_meal_cost;

CREATE TABLE hotel_revenue_meal_cost (
    meal TEXT,
    cost FLOAT
);

COPY hotel_revenue_meal_cost
FROM 'C:/SQL DATA/hotel_revenue_meal_cost.csv'
DELIMITER ','
CSV HEADER;


/*----------------------------------------------------------
7) Create final integrated dataset with JOINs
----------------------------------------------------------*/
DROP TABLE IF EXISTS hotel_revenue_all;

CREATE TABLE hotel_revenue_all AS
SELECT
    r.*,
    ms.discount,
    mc.cost AS meal_cost
FROM hotel_revenue r
LEFT JOIN hotel_revenue_market_segment ms
    ON r.market_segment = ms.market_segment
LEFT JOIN hotel_revenue_meal_cost mc
    ON r.meal = mc.meal;


/*----------------------------------------------------------
8) Preview a sample of final dataset
----------------------------------------------------------*/
SELECT *
FROM hotel_revenue_all
LIMIT 10 OFFSET 25000;
