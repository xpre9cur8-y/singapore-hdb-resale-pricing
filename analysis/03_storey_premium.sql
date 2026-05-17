-- 03_storey_premium.sql

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
	
