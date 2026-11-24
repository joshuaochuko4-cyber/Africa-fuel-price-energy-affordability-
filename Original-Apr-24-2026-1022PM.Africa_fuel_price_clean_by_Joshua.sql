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