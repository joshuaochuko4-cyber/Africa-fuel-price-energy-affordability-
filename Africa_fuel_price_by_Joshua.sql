SELECT COUNT (*) AS total_rows FROM africa_fuel_price_raw;

SELECT country, COUNT (*) AS cnt FROM africa_fuel_price_raw
GROUP BY country
ORDER BY COUNT (*) DESC;

SELECT fuel_type, COUNT (*) AS cnt
FROM africa_fuel_price_raw
GROUP BY fuel_type
ORDER BY COUNT (*) DESC;

-- Currency variants
SELECT currency, COUNT (*) AS cnt
FROM africa_fuel_price_raw
GROUP BY currency
ORDER BY COUNT (*) DESC;

SELECT
   SUM(CASE WHEN price         = '' OR price         IS NULL THEN 1 ELSE 0 END) AS missing_price,
   SUM(CASE WHEN date_recorded = '' OR date_recorded IS NULL THEN 1 ELSE 0 END) AS missing_date,
   SUM(CASE WHEN region_state  = '' OR region_state  IS NULL THEN 1 ELSE 0 END) AS missing_region,
   SUM(CASE WHEN lat           = '' OR lat           IS NULL THEN 1 ELSE 0 END) AS missing_lat,
   SUM(CASE WHEN min_daily_wage_local= '' OR min_daily_wage_local IS NULL THEN 1 ELSE 0 END) AS missing_wage
FROM africa_fuel_price_raw;

SELECT country, region_state, fuel_type, price, date_recorded, COUNT(*) AS cnt
FROM africa_fuel_price_raw
GROUP BY country, region_state, fuel_type, price, date_recorded
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

SELECT TOP 20 record_id, country, price
FROM africa_fuel_price_raw
WHERE price LIKE '-%';
 

SELECT TOP 20 record_id, country, fuel_type, price
FROM africa_fuel_price_raw
WHERE price LIKE '%[^0-9.,]%'
  OR price = '';

  UPDATE africa_fuel_price_raw
  SET country = CASE
   WHEN UPPER(LTRIM(RTRIM(country))) IN (
        'NIGERIA','NGR','NG','FED REP NIGERIA',
        'FEDERAL REPUBLIC OF NIGERIA','NIGÉRIA'
   ) THEN 'Nigeria'
 
   WHEN UPPER(LTRIM(RTRIM(country))) IN (
        'GHANA','GH','GHA','REPUBLIC OF GHANA'
   ) THEN 'Ghana'
 
   WHEN UPPER(LTRIM(RTRIM(country))) IN (
        'KENYA','KE','KEN','REPUBLIC OF KENYA'
   ) THEN 'Kenya'
 
   WHEN UPPER(LTRIM(RTRIM(country))) IN (
        'SOUTH AFRICA','SA','ZA','RSA',
        'S. AFRICA','S.AFRICA','SOUTH_AFRICA'
   ) THEN 'South Africa'
 
   WHEN UPPER(LTRIM(RTRIM(country))) IN (
        'EGYPT','EG','ARE','EGY',
        'ARAB REPUBLIC OF EGYPT','ÉGYPTE'
   ) THEN 'Egypt'
 
   WHEN UPPER(LTRIM(RTRIM(country))) IN (
        'ETHIOPIA','ET','ETH',
        'FEDERAL DEMOCRATIC REPUBLIC OF ETHIOPIA','ETHIOPIE'
   ) THEN 'Ethiopia'
 
   ELSE 'UNKNOWN'
END;
GO

SELECT DISTINCT country FROM africa_fuel_price_raw ORDER BY country;

UPDATE africa_fuel_price_raw
SET currency = CASE
   WHEN UPPER(LTRIM(RTRIM(currency))) IN (
        'NGN','NAIRA','NIGERIAN NAIRA','N'
   ) THEN 'NGN'
 
   WHEN UPPER(LTRIM(RTRIM(currency))) IN (
        'GHS','CEDIS','GHANA CEDIS','CEDI','GHC'
   ) THEN 'GHS'
 
   WHEN UPPER(LTRIM(RTRIM(currency))) IN (
        'KES','KENYAN SHILLING','KSH','KENYA SHILLING'
   ) THEN 'KES'
 
   WHEN UPPER(LTRIM(RTRIM(currency))) IN (
        'ZAR','RAND','SOUTH AFRICAN RAND','R'
   ) THEN 'ZAR'
 
   WHEN UPPER(LTRIM(RTRIM(currency))) IN (
        'EGP','EGYPTIAN POUND','LE'
   ) THEN 'EGP'
 
   WHEN UPPER(LTRIM(RTRIM(currency))) IN (
        'ETB','BIRR','ETHIOPIAN BIRR','BR'
   ) THEN 'ETB'
 
   ELSE 'UNKNOWN'
END;
GO

SELECT DISTINCT currency FROM africa_fuel_price_raw ORDER BY currency;


UPDATE africa_fuel_price_raw SET price = LTRIM(RTRIM(price));
GO
 
UPDATE africa_fuel_price_raw
SET price =
   LTRIM(RTRIM(
       REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
       REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
       REPLACE(REPLACE(REPLACE(
           price,
       'NGN ',''),'Naira ',''),'N ',''),
       'GHS ',''),'GHC ',''),'Cedis ',''),
       'KES ',''),'Ksh ',''),'KSH ',''),
       'ZAR ',''),'Rand ',''),'R ',''),
       'EGP ',''),'LE ',''),
       'ETB ',''))
   );
GO
 
UPDATE africa_fuel_price_raw
SET price = REPLACE(price, ',', '')
WHERE price NOT LIKE '%.%'
 AND price LIKE '%,%';
GO
 
UPDATE africa_fuel_price_raw
SET price = REPLACE(price, ',', '.')
WHERE price LIKE '%,[0-9][0-9]'
  OR price LIKE '%,[0-9]';
GO
 
UPDATE africa_fuel_price_raw SET price = LTRIM(RTRIM(price));
GO
 
SELECT TOP 20 record_id, price
FROM africa_fuel_price_raw
WHERE price LIKE '%[^0-9.]%'
 AND price != '';


 -- Step 9A: Add the clean date column
ALTER TABLE africa_fuel_price_raw
ADD date_clean DATE NULL;
GO
 
-- Step 9B: Handle YYYY-MM-DD format (e.g. 2023-03-01)
UPDATE africa_fuel_price_raw
SET date_clean = TRY_CONVERT(DATE, date_recorded, 120)
WHERE date_recorded LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
 AND date_clean IS NULL;
GO
 
-- Step 9C: Handle DD/MM/YYYY format (e.g. 01/03/2023)
UPDATE africa_fuel_price_raw
SET date_clean = TRY_CONVERT(DATE, date_recorded, 103)
WHERE date_recorded LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]'
 AND date_clean IS NULL;
GO
 
-- Step 9D: Handle DD.MM.YYYY format (e.g. 23.02.2023)
UPDATE africa_fuel_price_raw
SET date_clean = TRY_CONVERT(DATE, date_recorded, 104)
WHERE date_recorded LIKE '[0-9][0-9].[0-9][0-9].[0-9][0-9][0-9][0-9]'
 AND date_clean IS NULL;
GO
 
-- Step 9E: Handle YYYY/MM/DD format (e.g. 2023/03/01)
UPDATE africa_fuel_price_raw
SET date_clean = TRY_CONVERT(DATE,
   REPLACE(date_recorded,'/','-'), 120)
WHERE date_recorded LIKE '[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]'
 AND date_clean IS NULL;
GO
 
-- Step 9F: Handle MM-DD-YYYY format (e.g. 03-01-2023)
UPDATE africa_fuel_price_raw
SET date_clean = TRY_CONVERT(DATE, date_recorded, 110)
WHERE date_recorded LIKE '[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'
 AND date_clean IS NULL;
GO
 
-- Step 9G: Handle Mon-YY format (e.g. Jun-23, Sep-23)
-- Convert to '01-Jun-23' first so SQL Server can parse it
UPDATE africa_fuel_price_raw
SET date_clean = TRY_CONVERT(DATE,
   '01-' + date_recorded, 6)
WHERE date_recorded LIKE '[A-Z][a-z][a-z]-[0-9][0-9]'
 AND date_clean IS NULL;
GO
 
-- Step 9H: Handle 'Month YYYY' format (e.g. March 2023, Dec 2023)
UPDATE africa_fuel_price_raw
SET date_clean = TRY_CONVERT(DATE,
   '01 ' + date_recorded)
WHERE date_recorded LIKE '[A-Z]%[0-9][0-9][0-9][0-9]'
 AND LEN(date_recorded) <= 12
 AND date_clean IS NULL;
GO
 
-- Step 9I: Handle 'Month DD YYYY' format (e.g. March 1 2023)
UPDATE africa_fuel_price_raw
SET date_clean = TRY_CONVERT(DATE, date_recorded)
WHERE date_recorded LIKE '[A-Z]%[0-9] [0-9][0-9][0-9][0-9]'
 AND date_clean IS NULL;
GO
 
-- Step 9J: Check how many dates remain unparsed
SELECT COUNT(*) AS unparsed_dates
FROM africa_fuel_price_raw
WHERE date_clean IS NULL
 AND LTRIM(RTRIM(date_recorded)) != '';
 
-- Step 9K: Review what failed (invalid dates like 32/03/2023)
SELECT TOP 20 record_id, date_recorded
FROM africa_fuel_price_raw
WHERE date_clean IS NULL
 AND LTRIM(RTRIM(date_recorded)) != '';


 -- Standardize subsidy_applied to '1', '0', or NULL
UPDATE africa_fuel_price_raw
SET subsidy_applied = CASE
   WHEN UPPER(LTRIM(RTRIM(subsidy_applied))) IN ('YES','Y','1','TRUE') THEN '1'
   WHEN UPPER(LTRIM(RTRIM(subsidy_applied))) IN ('NO','N','0','FALSE') THEN '0'
   ELSE NULL  -- '?', 'unknown', '', N/A all become NULL
END;
GO
 
-- Standardize Pump_or_BlackMarket
UPDATE africa_fuel_price_raw
SET Pump_or_BlackMarket = CASE
   WHEN UPPER(LTRIM(RTRIM(Pump_or_BlackMarket))) IN (
        'PUMP','OFFICIAL PUMP','OFFICIAL',
        'FILLING STATION','OFFICIAL PUMP'
   ) THEN 'Official Pump'
   WHEN UPPER(LTRIM(RTRIM(Pump_or_BlackMarket))) IN (
        'BLACK MARKET','BLACKMARKET','BM',
        'BLACK MKT'
   ) THEN 'Black Market'
   ELSE 'Unknown'
END;
GO

SELECT Pump_or_BlackMarket,
COUNT (*) AS cnt
FROM africa_fuel_price_raw
GROUP BY Pump_or_BlackMarket
ORDER BY COUNT (*) DESC;

-- Remove currency symbols and text from wage column
UPDATE africa_fuel_price_raw
SET Min_Daily_Wage_Local = LTRIM(RTRIM(
   REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
       REPLACE(Min_Daily_Wage_Local,
       'NGN',''),'GHS',''),'KES',''),
       'ETB',''),'EGP',''),'ZAR','')
));
GO
 
-- Remove thousands-separator commas (e.g. 18,000 -> 18000)
UPDATE africa_fuel_price_raw
SET Min_Daily_Wage_Local = REPLACE(Min_Daily_Wage_Local, ',', '')
WHERE Min_Daily_Wage_Local LIKE '%,%'
 AND Min_Daily_Wage_Local NOT LIKE '%.%';
GO
 
-- Null out invalid / unrecognised wage values
UPDATE africa_fuel_price_raw
SET Min_Daily_Wage_Local = NULL
WHERE LTRIM(RTRIM(ISNULL(Min_Daily_Wage_Local,''))) IN (
     '?','unknown','Unknown','N/A','','0'
)
OR Min_Daily_Wage_Local LIKE '%[^0-9.]%';
GO

-- Step 12A: First count duplicates
SELECT country, region_state, fuel_type, price, date_recorded,
      COUNT(*) AS duplicate_count
FROM africa_fuel_price_raw
GROUP BY country, region_state, fuel_type, price, date_recorded
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;
 
-- Step 12B: Delete duplicates using CTE (SQL Server method)
;WITH CTE_Duplicates AS (
   SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY country, region_state, fuel_type, price, date_recorded
           ORDER BY TRY_CAST(record_id AS INT) ASC
       ) AS row_num
   FROM africa_fuel_price_raw
)
DELETE FROM CTE_Duplicates
WHERE row_num > 1;
GO
 
-- Step 12C: Confirm no duplicates remain
SELECT country, region_state, fuel_type, price, date_recorded, COUNT(*) AS cnt
FROM africa_fuel_price_raw
GROUP BY country, region_state, fuel_type, price, date_recorded
HAVING COUNT(*) > 1;
-- Expected result: 0 rows returned

-- Flag negative prices
UPDATE africa_fuel_price_raw
SET reporter_notes = ISNULL(reporter_notes,'') + ' | FLAG:negative_price'
WHERE price LIKE '-%';
GO
 
-- Flag missing prices
UPDATE africa_fuel_price_raw
SET reporter_notes = ISNULL(reporter_notes,'') + ' | FLAG:missing_price'
WHERE LTRIM(RTRIM(ISNULL(price,''))) = '';
GO
 
-- Flag outlier prices (country-specific thresholds)
UPDATE africa_fuel_price_raw
SET reporter_notes = ISNULL(reporter_notes,'') + ' | FLAG:outlier_price'
WHERE price NOT LIKE '%[^0-9.]%'
 AND price != ''
 AND (
   (country = 'Nigeria'      AND TRY_CAST(price AS DECIMAL(12,2)) > 2000)  OR
   (country = 'Ghana'        AND TRY_CAST(price AS DECIMAL(12,2)) > 30)    OR
   (country = 'Kenya'        AND TRY_CAST(price AS DECIMAL(12,2)) > 400)   OR
   (country = 'South Africa' AND TRY_CAST(price AS DECIMAL(12,2)) > 40)    OR
   (country = 'Egypt'        AND TRY_CAST(price AS DECIMAL(12,2)) > 25)    OR
   (country = 'Ethiopia'     AND TRY_CAST(price AS DECIMAL(12,2)) > 100)
 );
GO
 
-- Flag unknown countries
UPDATE africa_fuel_price_raw
SET reporter_notes = ISNULL(reporter_notes,'') + ' | FLAG:unknown_country'
WHERE country = 'UNKNOWN';
GO
 
-- Summary: count all flagged rows by type
SELECT
   SUM(CASE WHEN reporter_notes LIKE '%negative_price%'  THEN 1 ELSE 0 END) AS negative_prices,
   SUM(CASE WHEN reporter_notes LIKE '%missing_price%'   THEN 1 ELSE 0 END) AS missing_prices,
   SUM(CASE WHEN reporter_notes LIKE '%outlier_price%'   THEN 1 ELSE 0 END) AS outlier_prices,
   SUM(CASE WHEN reporter_notes LIKE '%unknown_country%' THEN 1 ELSE 0 END) AS bad_country
FROM africa_fuel_price_raw;

-- SQL Server does not have INITCAP, so we fix known problem regions manually
 
UPDATE africa_fuel_price_raw SET region_state = 'Greater Accra'
WHERE UPPER(region_state) = 'GREATER ACCRA';
 
UPDATE africa_fuel_price_raw SET region_state = 'Abuja FCT'
WHERE UPPER(region_state) = 'ABUJA FCT';
 
UPDATE africa_fuel_price_raw SET region_state = 'KwaZulu-Natal'
WHERE UPPER(region_state) = 'KWAZULU-NATAL';
 
UPDATE africa_fuel_price_raw SET region_state = 'Western Cape'
WHERE UPPER(region_state) = 'WESTERN CAPE';
 
UPDATE africa_fuel_price_raw SET region_state = 'Addis Ababa'
WHERE UPPER(region_state) = 'ADDIS ABABA';
 
UPDATE africa_fuel_price_raw SET region_state = 'North Eastern'
WHERE UPPER(region_state) = 'NORTH EASTERN';
 
UPDATE africa_fuel_price_raw SET region_state = 'Rift Valley'
WHERE UPPER(region_state) = 'RIFT VALLEY';
 
-- Fix all-lowercase regions
-- SQL Server trick: use UPPER first letter + LOWER rest
UPDATE africa_fuel_price_raw
SET region_state =
   UPPER(LEFT(LTRIM(region_state),1)) +
   LOWER(SUBSTRING(LTRIM(region_state),2,LEN(region_state)))
WHERE region_state = LOWER(region_state)
 AND region_state != ''
 AND region_state IS NOT NULL;
GO