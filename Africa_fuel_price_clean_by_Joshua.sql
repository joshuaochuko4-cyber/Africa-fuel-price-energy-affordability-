SELECT
    TRY_CAST(record_id AS INT) AS record_id,
    country,
    LTRIM(RTRIM(region_state)) AS region_state,
    fuel_type,
    TRY_CAST(price AS DECIMAL(12,2)) AS price_local,
    currency,
    date_clean AS date_recorded,
    YEAR(date_clean) AS year,
    MONTH(date_clean) AS month_num,
    DATENAME(MONTH, date_clean) AS month_name,
    DATEPART(QUARTER, date_clean) AS quarter,
    data_source,
    TRY_CAST(subsidy_applied AS TINYINT) AS subsidy_applied,
     Pump_or_BlackMarket AS price_channel,
    TRY_CAST(Min_Daily_Wage_Local AS DECIMAL(12,2)) AS min_daily_wage_local,
    TRY_CAST(lat AS DECIMAL(10,6)) AS latitude,
    TRY_CAST(long AS DECIMAL(10,6)) AS longitude,
    LTRIM(RTRIM(ISNULL(reporter_notes,''))) AS notes

INTO africa_fuel_price_clean_final  -- This creates the new table

FROM africa_fuel_price_raw

WHERE 
    country IN ('Nigeria','Ghana','Kenya','South Africa','Egypt','Ethiopia')
    AND price NOT LIKE '%[^0-9.]%'
    AND LTRIM(RTRIM(ISNULL(price,''))) != ''
    AND TRY_CAST(price AS DECIMAL(12,2)) > 0
    AND ISNULL(reporter_notes,'') NOT LIKE '%negative_price%'
    AND ISNULL(reporter_notes,'') NOT LIKE '%outlier_price%'
    AND date_clean IS NOT NULL
    AND fuel_type != 'Other/Unknown';
GO
 
-- Add primary key to clean table
ALTER TABLE african_fuel_price_clean_final
ADD CONSTRAINT PK_fuel_clean PRIMARY KEY (record_id);
GO
 
-- Final row count
SELECT COUNT(*) AS clean_rows FROM africa_fuel_price_clean_final;

DROP TABLE IF EXISTS africa_fuel_price_raw_clean;
GO


DROP TABLE IF EXISTS africa_fuel_price_clean_final;
GO

SELECT
    TRY_CAST(record_id AS INT) AS record_id,
    country,
    LTRIM(RTRIM(region_state)) AS region_state,
    fuel_type,
    TRY_CAST(price AS DECIMAL(12,2)) AS price_local,
    currency,
    date_clean AS date_recorded,
    YEAR(date_clean) AS year,
    MONTH(date_clean) AS month_num,
    DATENAME(MONTH, date_clean) AS month_name,
    DATEPART(QUARTER, date_clean) AS quarter,
    data_source,
    TRY_CAST(subsidy_applied AS TINYINT) AS subsidy_applied,
     Pump_or_BlackMarket AS price_channel,
    TRY_CAST(Min_Daily_Wage_Local AS DECIMAL(12,2)) AS min_daily_wage_local,
    TRY_CAST(lat AS DECIMAL(10,6)) AS latitude,
    TRY_CAST(long AS DECIMAL(10,6)) AS longitude,
    LTRIM(RTRIM(ISNULL(reporter_notes,''))) AS notes

INTO africa_fuel_price_raw_clean  -- This creates the new table

FROM africa_fuel_price_raw

WHERE 
    country IN ('Nigeria','Ghana','Kenya','South Africa','Egypt','Ethiopia')
    AND price NOT LIKE '%[^0-9.]%'
    AND TRY_CAST(price AS DECIMAL(12,2)) > 0
    AND ISNULL(reporter_notes,'') NOT LIKE '%negative_price%'
    AND ISNULL(reporter_notes,'') NOT LIKE '%outlier_price%'
    AND date_clean IS NOT NULL
    AND fuel_type != 'Other/Unknown';

	SELECT
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS record_id,
	country,
    region_state,
    fuel_type,
    price_local,
    currency,
    date_recorded,
    year,
    month_num,
    month_name,
    quarter,
    data_source,
    subsidy_applied,
    price_channel,
    min_daily_wage_local,
    latitude,
    longitude,
    notes
	INTO africa_fuel_price_clean_final
	FROM africa_fuel_price_raw_clean;

	SELECT record_id, COUNT(*)
	FROM africa_fuel_price_raw_clean
	GROUP BY record_id
	HAVING COUNT(*) > 1;

	SELECT *
	FROM africa_fuel_price_raw_clean
	WHERE record_id IS NULL;

	SELECT COUNT(*) AS clean_rows FROM africa_fuel_price_raw_clean;

	-- CHECK 1: Row count before and after
SELECT
   (SELECT COUNT(*) FROM africa_fuel_price_raw)   AS raw_rows,
   (SELECT COUNT(*) FROM africa_fuel_price_raw_clean) AS clean_rows;
 
-- CHECK 2: Country distribution
SELECT country, COUNT(*) AS rows
FROM africa_fuel_price_raw_clean
GROUP BY country
ORDER BY COUNT(*) DESC;
 
-- CHECK 3: Fuel type distribution
SELECT fuel_type, COUNT(*) AS rows
FROM africa_fuel_price_raw_clean
GROUP BY fuel_type
ORDER BY COUNT(*) DESC;
 
-- CHECK 4: Date range
SELECT
   MIN(date_recorded) AS earliest_date,
   MAX(date_recorded) AS latest_date
FROM africa_fuel_price_raw_clean;
 
-- CHECK 5: No NULLs in critical columns
SELECT
   SUM(CASE WHEN price_local   IS NULL THEN 1 ELSE 0 END) AS null_price,
   SUM(CASE WHEN date_recorded IS NULL THEN 1 ELSE 0 END) AS null_date,
   SUM(CASE WHEN country       IS NULL THEN 1 ELSE 0 END) AS null_country,
   SUM(CASE WHEN currency      IS NULL THEN 1 ELSE 0 END) AS null_currency
FROM africa_fuel_price_raw_clean;
-- All values should be 0
 
-- CHECK 6: No duplicates remain
SELECT country, region_state, fuel_type, date_recorded, COUNT(*) AS cnt
FROM africa_fuel_price_raw_clean
GROUP BY country, region_state, fuel_type, date_recorded
HAVING COUNT(*) > 1;
-- Expected: 0 rows returned
 
-- CHECK 7: Price ranges per country
SELECT
   country,
   MIN(price_local)              AS min_price,
   MAX(price_local)              AS max_price,
   ROUND(AVG(price_local),2)     AS avg_price
FROM africa_fuel_price_raw_clean
GROUP BY country
ORDER BY country;
 
-- CHECK 8: Year distribution
SELECT year, COUNT(*) AS rows
FROM africa_fuel_price_raw_clean
GROUP BY year
ORDER BY year;
 
-- CHECK 9: Subsidy coverage per country
SELECT
   country,
   SUM(CAST(subsidy_applied AS INT))  AS subsidised_records,
   COUNT(*)                           AS total,
   ROUND(
       100.0 * SUM(CAST(subsidy_applied AS INT)) / COUNT(*),
   1) AS pct_subsidised
FROM africa_fuel_price_raw_clean
GROUP BY country;

-- Create a summary table for the Power BI Data Quality page
SELECT 'Raw Records'              AS metric,
      CAST(COUNT(*) AS VARCHAR)  AS value
INTO data_quality_summary
FROM africa_fuel_price_raw
 
UNION ALL
SELECT 'Clean Records',
      CAST((SELECT COUNT(*) FROM africa_fuel_price_raw_clean) AS VARCHAR)
 
UNION ALL
SELECT 'Duplicates Removed',
      CAST((
          SELECT COUNT(*) FROM africa_fuel_price_raw
          WHERE reporter_notes LIKE '%DUPLICATE%'
      ) AS VARCHAR)
 
UNION ALL
SELECT 'Negative Prices Removed',
      CAST((
          SELECT COUNT(*) FROM africa_fuel_price_raw
          WHERE reporter_notes LIKE '%negative_price%'
      ) AS VARCHAR)
 
UNION ALL
SELECT 'Outliers Removed',
      CAST((
          SELECT COUNT(*) FROM africa_fuel_price_raw
          WHERE reporter_notes LIKE '%outlier_price%'
      ) AS VARCHAR)
 
UNION ALL
SELECT 'Invalid Dates (NULL)',
      CAST((
          SELECT COUNT(*) FROM africa_fuel_price_raw
          WHERE date_clean IS NULL
            AND LTRIM(RTRIM(date_recorded)) != ''
      ) AS VARCHAR);
GO
 
-- View the summary
SELECT * FROM data_quality_summary;

SELECT 
    country,
    price_channel,
    AVG(price_local) AS avg_price,
    MAX(price_local) AS max_price,
    COUNT(*) AS records
FROM africa_fuel_price_clean_final
WHERE price_channel = 'Black Market'
GROUP BY country, price_channel
ORDER BY avg_price DESC;

-- Remove remaining black market outliers
DELETE FROM africa_fuel_price_clean_final
WHERE price_channel = 'Black Market'
AND (
    (country = 'Nigeria'      AND price_local > 2000)  OR
    (country = 'Ghana'        AND price_local > 50)    OR
    (country = 'Kenya'        AND price_local > 500)   OR
    (country = 'South Africa' AND price_local > 60)    OR
    (country = 'Egypt'        AND price_local > 30)    OR
    (country = 'Ethiopia'     AND price_local > 150)
);
GO

-- Verify after deletion
SELECT country, price_channel, 
       AVG(price_local) AS avg_price,
       MAX(price_local) AS max_price
FROM africa_fuel_price_clean_final
WHERE price_channel = 'Black Market'
GROUP BY country, price_channel
ORDER BY country;

-- Check Nigeria black market price distribution
SELECT 
    price_local,
    COUNT(*) AS records
FROM africa_fuel_price_clean_final
WHERE country = 'Nigeria'
AND price_channel = 'Black Market'
AND price_local > 1500
GROUP BY price_local
ORDER BY price_local DESC;

-- Remove unrealistic Nigeria black market prices
DELETE FROM africa_fuel_price_clean_final
WHERE country = 'Nigeria'
AND price_channel = 'Black Market'
AND price_local > 1500;
GO

-- Verify Nigeria black market after fix
SELECT 
    country,
    price_channel,
    AVG(price_local) AS avg_price,
    MAX(price_local) AS max_price,
    COUNT(*) AS records
FROM africa_fuel_price_clean_final
WHERE country = 'Nigeria'
AND price_channel = 'Black Market'
GROUP BY country, price_channel;

-- See full distribution of Nigeria black market prices
SELECT 
    CASE 
        WHEN price_local BETWEEN 0   AND 500  THEN '0-500'
        WHEN price_local BETWEEN 501 AND 700  THEN '501-700'
        WHEN price_local BETWEEN 701 AND 900  THEN '701-900'
        WHEN price_local BETWEEN 901 AND 1100 THEN '901-1100'
        WHEN price_local BETWEEN 1101 AND 1300 THEN '1101-1300'
        WHEN price_local BETWEEN 1301 AND 1500 THEN '1301-1500'
    END AS price_range,
    COUNT(*) AS records,
    AVG(price_local) AS avg_in_range
FROM africa_fuel_price_clean_final
WHERE country = 'Nigeria'
AND price_channel = 'Black Market'
GROUP BY 
    CASE 
        WHEN price_local BETWEEN 0   AND 500  THEN '0-500'
        WHEN price_local BETWEEN 501 AND 700  THEN '501-700'
        WHEN price_local BETWEEN 701 AND 900  THEN '701-900'
        WHEN price_local BETWEEN 901 AND 1100 THEN '901-1100'
        WHEN price_local BETWEEN 1101 AND 1300 THEN '1101-1300'
        WHEN price_local BETWEEN 1301 AND 1500 THEN '1301-1500'
    END
ORDER BY price_range;

-- Delete old raw records count
DELETE FROM data_quality_summary
WHERE metric = 'Raw Records';

-- Insert correct count
INSERT INTO data_quality_summary (metric, value)
SELECT 
    'Raw Records',
    CAST(COUNT(*) AS VARCHAR)
FROM africa_fuel_price_raw_clean;

-- Verify
SELECT * FROM data_quality_summary;

-- First check what is currently in your summary table
SELECT * FROM data_quality_summary;

-- Check actual row count of raw table
SELECT COUNT(*) AS raw_count FROM africa_fuel_price_raw;

-- Check actual row count of clean table  
SELECT COUNT(*) AS clean_count 
FROM africa_fuel_price_clean_final;

-- Delete all wrong values
DELETE FROM data_quality_summary;

-- Insert correct accurate values
INSERT INTO data_quality_summary (metric, value)
VALUES 
    ('Raw Records',              '119922'),
    ('Clean Records',            '68350'),
    ('Records Removed',          '51572'),
    ('Negative Prices Removed',  '629'),
    ('Outliers Removed',         '13366'),
    ('Invalid Dates Fixed',      '21667'),
    ('Missing Prices',           '600'),
    ('Duplicates Removed',       '6000');
GO

-- Verify
SELECT * FROM data_quality_summary;