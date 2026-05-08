/*
  Question: Do large enterprises lead SMEs in AI adoption, or are SMEs catching up?
  Insight: Tells the client which segment to prioritise for outreach.
*/

SELECT 
  f.employee_size,
  dy.year,
  COUNT(*) AS companies,
  ROUND(AVG(f.ai_maturity_score)::numeric, 2) AS avg_maturity,
  ROUND(AVG(f.ai_roi_percent)::numeric, 2) AS avg_roi
FROM fact_ai_adoption f
JOIN dim_year dy ON f.year_id = dy.year_id
GROUP BY f.employee_size, dy.year
ORDER BY f.employee_size, dy.year;

/*
  Are Enterprise companies more polarised than SMEs?
  Same average could mask very different distributions.
*/

SELECT 
  f.employee_size,
  CASE 
    WHEN f.ai_maturity_score >= 80 THEN '1. Leader'
    WHEN f.ai_maturity_score >= 50 THEN '2. Adopter'
    ELSE '3. Laggard'
  END AS tier,
  COUNT(*) AS companies,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY f.employee_size), 1) AS pct_of_segment
FROM fact_ai_adoption f
JOIN dim_year dy ON f.year_id = dy.year_id
WHERE dy.year = 2025
GROUP BY f.employee_size, tier
ORDER BY f.employee_size, tier;

AI maturity distribution is virtually identical between Enterprise and SME companies (Leaders: 10.8% vs 12.0%, 
Laggards: 35.0% vs 37.6%). Company size does not predict AI maturity. The consulting segmentation should focus 
on industry and current maturity tier rather than company size.