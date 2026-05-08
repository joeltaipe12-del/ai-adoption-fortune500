/*
  Question: How are companies distributed across AI maturity tiers?
  Insight: Most consulting opportunity is in the Adopter tier — too mature to be hopeless, not yet leaders.
*/

SELECT 
  CASE 
    WHEN f.ai_maturity_score >= 80 THEN '1. Leader (80+)'
    WHEN f.ai_maturity_score >= 50 THEN '2. Adopter (50-79)'
    ELSE '3. Laggard (<50)'
  END AS maturity_tier,
  COUNT(*) AS companies,
  ROUND(AVG(f.revenue_usd)::numeric, 0) AS avg_revenue
FROM fact_ai_adoption f
JOIN dim_year dy ON f.year_id = dy.year_id
WHERE dy.year = 2025
GROUP BY maturity_tier
ORDER BY maturity_tier;

/* Only 11.5% of Fortune 500 companies qualify as AI Leaders (maturity 80+), while 36.5% remain Laggards below 50. 
 * Leaders average $46.2B in revenue — 4.3x more than Laggards ($10.7B). The 520 companies in the Adopter tier (50-79) 
 * represent the primary consulting opportunity: they've committed 
 to AI but haven't reached maturity. /*