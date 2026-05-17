-- 05_million_flat_profiling.sql

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
