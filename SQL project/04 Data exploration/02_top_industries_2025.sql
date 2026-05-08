/*
  Question: Which industries lead AI maturity in the most recent year?
  Insight: Identifies the leaders for the consulting firm's targeting.
*/

SELECT 
  di.industry_name,
  ROUND(AVG(f.ai_maturity_score)::numeric, 2) AS avg_maturity,
  COUNT(*) AS companies
FROM fact_ai_adoption f
JOIN dim_industry di ON f.industry_id = di.industry_id
JOIN dim_year dy ON f.year_id = dy.year_id
WHERE dy.year = 2025
GROUP BY di.industry_name
having COUNT(*) >= 30
ORDER BY avg_maturity desc
limit 5; 

/*
Energy and Finance lead AI maturity in 2025 at 57.4 and 56.1 respectively, 
while Technology ranks only 3rd at 55.2 — suggesting that AI maturity is driven
more by operational application than by being a tech company. The narrow 2.8-point 
spread across the top 5 indicates the market remains wide open with no dominant sector.
/*