-- 01_data_checks.sql
-- data checks, cleaning and analysis

-- GENERAL ANALYSIS

-- row count 
SELECT
	COUNT(*) AS total_rows
FROM
	resale_transactions;

-- date range
SELECT
	MIN(MONTH) AS earliest_transaction,
	MAX(MONTH) AS latest_transaction
FROM
	resale_transactions;

-- check NULLS
SELECT
    SUM(CASE WHEN resale_price     IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN town             IS NULL THEN 1 ELSE 0 END) AS null_town,
    SUM(CASE WHEN flat_type        IS NULL THEN 1 ELSE 0 END) AS null_flat_type,
    SUM(CASE WHEN floor_area_sqm   IS NULL THEN 1 ELSE 0 END) AS null_floor_area,
    SUM(CASE WHEN storey_range     IS NULL THEN 1 ELSE 0 END) AS null_storey
FROM 
	resale_transactions;

-- price range, price average
SELECT
    MIN(resale_price)        AS min_price,
    MAX(resale_price)        AS max_price,
    ROUND(AVG(resale_price)) AS avg_price
FROM 
	resale_transactions;

-- DISTINCT flat types
SELECT 
	flat_type,
	COUNT(*) AS count
FROM resale_transactions
GROUP BY flat_type;

-- DISTINCT flat models
SELECT
	flat_model,
	COUNT(*) AS COUNT
FROM resale_transactions
GROUP BY flat_model
ORDER BY COUNT DESC;

-- transactions across the years
SELECT
    LEFT(month::TEXT, 4) AS year,
    COUNT(*) AS num_transactions
FROM resale_transactions
GROUP BY LEFT(month::TEXT, 4)
ORDER BY num_transactions DESC;

-- price per sqm (psm) 
SELECT
    ROUND(MIN(resale_price / floor_area_sqm)) AS min_psm,
    ROUND(MAX(resale_price/ floor_area_sqm)) AS max_psm,
    ROUND(AVG(resale_price / floor_area_sqm)) AS avg_psm
FROM 
	resale_transactions;
