-- 04_appreaciation.sql

-- Town Appreciation Rankings
-- Business Question: Which towns have appreciated the fastest since 2017, and which have only recently started rising? 
-- Some towns may have reached ceiling prices, while others have potential growth and more future room to run depending on the years
-- For this objective, will demonstrate appreaciation findings on 4 ROOM FLATS due to size/layout/pricing structure differences. Of course, this can be filtered accordingly

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

