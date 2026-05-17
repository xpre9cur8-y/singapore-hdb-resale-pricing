-- analysis.sql
-- data checks, cleaning and analysis

/*

Question
Q1	Which towns have the highest price per sqm — and does raw price mislead buyers?
Q2	How much does floor level actually add to resale price? Is the premium worth it?
Q3	Which towns appreciated fastest since 2017, and which are catching up now?
Q4	Does remaining lease genuinely affect price, and by how much per decade lost?
Q5	Where are million-dollar flats concentrated, and is this spreading to new towns?
Q6	Which flat types offer the best value relative to size — the hidden sweet spot?

*/

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

/* 

	ANALYSIS QUERIES

*/

-- Business question: Which towns are genuinely expensive, and which just have large flats inflating the average?
-- (Avg) Raw resale price comparisons can be misleading at face value.  

SELECT 
	town,
	COUNT(*) AS town_transactions,
	AVG(resale_price) AS avg_resale_price,
	AVG(resale_price/floor_area_sqm) AS avg_price_psm, 
	MIN(resale_price/floor_area_sqm) AS min_price_psm, 
	MAX(resale_price/floor_area_sqm) AS max_price_psm
FROM
	resale_transactions
WHERE 
	month >= '2023-01-01' -- exclude outdated resale prices
  AND flat_type NOT IN ('1 ROOM', '2 ROOM')   -- exclude small outliers
GROUP BY
	town
	HAVING COUNT(*) >= 30 -- exclude smaller sample sizes
ORDER BY avg_price_psm DESC;


-- Business question: What is the actual price premium for each floor band? How much value do buyers place on high floors? How much does each additional floor band add to resale price?
-- CASE WHEN converts the raw storey_range string into comparable buckets.

-- table for floor band prices 
CREATE VIEW floor_prices AS
	SELECT  
	flat_type,
    CASE
        WHEN storey_range IN ('01 TO 03','04 TO 06') THEN '1 Low (01-06)'
        WHEN storey_range IN ('07 TO 09','10 TO 12') THEN '2 Mid (07-12)'
        WHEN storey_range IN ('13 TO 15','16 TO 18') THEN '3 Upper (13-18)'
        WHEN storey_range IN ('19 TO 21','22 TO 24') THEN '4 High (19-24)'
        ELSE '5 Premium (25+)'
    END AS floor_band,
    ROUND(AVG(resale_price)) AS avg_price,
	ROUND(AVG(resale_price/floor_area_sqm)) AS avg_price_psm,
	COUNT(*) AS transactions
	
	FROM resale_transactions
	WHERE MONTH >= '2023-01-01' -- relevancy
	GROUP BY 1, 2; 


-- personal checking for the first CTE
-- SELECT
-- 	*,
-- 		FIRST_VALUE(avg_price) OVER (
-- 			PARTITION BY flat_type
-- 			ORDER BY floor_band 
-- 		) AS low_floor_price
-- FROM floor_prices;


-- FIRST IS CTE
WITH baseline AS ( -- column for low_floor_price for each flat_type
	SELECT
	*,
		FIRST_VALUE(avg_price) OVER (
			PARTITION BY flat_type
			ORDER BY floor_band -- sort and grabs first value (lOW)
		) AS low_floor_price
	FROM floor_prices 
) SELECT 
	flat_type, 
	floor_band,
	avg_price,
	avg_price_psm,
	avg_price - low_floor_price AS premium_over_low, -- upper floors cost how much more than lower
	ROUND(((avg_price - low_floor_price) / low_floor_price)*100, 2) AS premium_psm_pct -- percentage premium, upper floors how much more exp than lower
FROM baseline
WHERE flat_type IN ('3 ROOM', '4 ROOM', '5 ROOM');  

/*

ANALYSIS

Based on the results, we can potentially visualise and analyst - linear growth. E.g. If premium_pct increases steadily (3.9% → 7.9% → 11.8%), the market values height consistently across all bands

OR cliff effects, outliers. E.g. If 25+ floors jump dramatically (18% when lower bands are 5-10%), high floors are a luxury segment with disproportionate pricing 

Comparing flat type differences

Transactions volume drop. Take note if transactions decrease for higher floors (like penthouses). Smaller sample sizes would also mean less reliable averages.

Business Implication: If a high-floor 3-room costs 18% more but only offers 2% more psm value, you're paying for prestige, not space. The sweet spot might be floors 19-24 where you get 80% of the premium at 65% of the cost.

*/
	
	
	
	
	
	
	
-- Town Appreciation Rankings
-- Business Question: Which towns have appreciated the fastest since 2017, and which have only recently started rising? 
-- Some towns may have reached ceiling prices, while others have potential growth and more future room to run depending on the years
-- For this questions, I will demonstrate appreaciation findings one 4 ROOM FLATS due to size/layout/pricing structure differences. Of course, this can be filtered. 


-- SELECT
--     town,
--     EXTRACT(YEAR FROM month) AS year,
--     ROUND(AVG(resale_price)) AS avg_price,
--     COUNT(*) AS transactions
-- FROM resale_transactions
-- WHERE flat_type = '4 ROOM'
-- GROUP BY town, year
-- HAVING COUNT(*) >= 10 
-- ORDER BY town, YEAR;

-- year to year comparisons 
-- SELECT 
-- 	town,
-- 	EXTRACT(YEAR FROM month) AS year,
-- 	ROUND(AVG(resale_price)) AS avg_price,
-- 	LAG(avg_price) 
-- 		OVER(
-- 			PARTITION BY town 
-- 			ORDER BY year) AS prev_year_avg
-- FROM resale_transactions;

-- SELECT
--     town,
--     EXTRACT(YEAR FROM month) AS year,
--     ROUND(AVG(resale_price)) AS avg_price,
--     COUNT(*) AS transactions
-- FROM resale_transactions
-- WHERE flat_type = '4 ROOM'
-- GROUP BY town, year
-- HAVING COUNT(*) >= 10 
-- ORDER BY town, YEAR;

-- year to year comparisons 
-- SELECT 
-- 	town,
-- 	EXTRACT(YEAR FROM month) AS year
-- three CTEs

WITH yearly_avg AS (

	SELECT
	    town,
	    EXTRACT(YEAR FROM month) AS year,
	    ROUND(AVG(resale_price)) AS avg_price,
	    COUNT(*) AS transactions
	FROM resale_transactions
	WHERE flat_type = '4 ROOM'
	GROUP BY town, year
	HAVING COUNT(*) >= 10 
	ORDER BY town, YEAR

), year_to_year AS (
	
	SELECT 
		town,
		year,
		avg_price, 
		LAG(avg_price) 
			OVER(
				PARTITION BY town 
				ORDER BY year) AS prev_year_avg -- creating new col based on current (avg_price) 
	FROM yearly_avg

), growth_pct AS(

	SELECT
		town,
		year, 
		avg_price,
		prev_year_avg,
		ROUND(((avg_price - prev_year_avg) / avg_price)*100, 2) AS growth_pct
	FROM year_to_year
	WHERE prev_year_avg IS NOT NULL
)
	SELECT *
	FROM growth_pct -- last CTE
	ORDER BY year DESC, growth_pct DESC; 	
	
/*

ANALYSIS: For 4 rooms

Most towns saw strong appreciation in 2025, with many recording:
	5 - 10% YoY growth
	Several above 10% as a whole

Highest 2025 gainers: Clementi, Bukit Timah, Central, Marine Parade, Toa Payoh
* On the consensus that 2026 may have incomplete data still

Mature estates also consistently command premium prices
	- Central, Queenstown, Toa Payoh, Kallang, Bukit Merah
	9
Non Mature estates remain more affordable but stable
	- Jurong West, Choa Chu Kang, Woodlands, Yishun
*/






-- Million-Dollar Flat Profiling
-- Where are million-dollar flats concentrated, which flat types drive this trend, and is it spreading to new towns?

WITH millions_by_town_year AS (

	SELECT
		town,
		LEFT(month::TEXT, 4) AS year,
		flat_type, 
		COUNT(*) AS transactions, 
		MAX(resale_price) AS highest_price
	FROM 
		resale_transactions
	WHERE resale_price >= 1000000
	GROUP BY town, year, flat_type

), town_totals AS (

	SELECT
		town, 
		flat_type,
		SUM(transactions) AS total_transactions,
		MAX(highest_price) AS highest_transaction,
		MIN(highest_price) AS lowest_transaction, 
		MIN(year) AS first_seen_year,
		RANK() OVER (ORDER BY SUM(transactions) DESC) AS town_rank
	FROM 
		millions_by_town_year
	GROUP BY town, flat_type
) 
	SELECT 
		*,
		CASE
	        WHEN first_seen_year::INTEGER >= 2022 THEN 'Emerging hotspot'
	        WHEN first_seen_year::INTEGER >= 2020 THEN 'Growing trend'
	        ELSE 'Established'
	    END AS trend_label
	FROM 
		town_totals;

/*

ANALYSIS: For million dollar transactions

Emerging Hotspots (2022 onward): Towns like Toa Payoh (4R), Kallang/Whampoa (4R), Tampines (EXEC), Bedok, Clementi, Geylang, Punggol, and Sengkang show recent spikes in million-dollar transactions.

Growing Trend (2020–2021): Ang Mo Kio, Queenstown, Toa Payoh (EXEC), and Geylang (5R), suggesting prices crossed the million-dollar mark relatively recently.

Established (before 2020): Bukit Merah, Queenstown, Central Area, Bishan, reflecting consistent high-value activity over several years.

Patterns by Flat Type
	4-room flats: Increasingly hitting the million-dollar mark in Emerging hotspots, e.g., Toa Payoh (2022), Clementi (2023), Geylang (2024).
	
	5-room flats: Predominantly in Established towns but also emerging in Bukit Timah, Punggol, and TAMPINES.
	Executive & Multi-generation: More likely in newer hotspots (e.g., Woodlands, Bedok, Bishan), suggesting rising demand for larger units.


*/


