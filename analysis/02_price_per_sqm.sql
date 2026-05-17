-- 02_price_per_sqm.sql

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