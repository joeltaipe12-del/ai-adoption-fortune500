/*
  Question: Which AI use cases deliver the highest average ROI?
  Insight: Helps the client recommend high-ROI use cases to their prospects.
*/

SELECT 
  duc.use_case_name,
  COUNT(*) AS companies,
  ROUND(AVG(f.ai_roi_percent)::numeric, 2) AS avg_roi,
  ROUND(AVG(f.ai_maturity_score)::numeric, 2) AS avg_maturity
FROM fact_ai_adoption f
JOIN dim_use_case duc ON f.use_case_id = duc.use_case_id
WHERE f.uses_ai_bool = TRUE
GROUP BY duc.use_case_name
ORDER BY avg_roi DESC;

 /*AI ROI is remarkably uniform across use cases, ranging only from 24.4% to 25.9%. This suggests that the choice of AI 
application matters less than industry context and execution quality. Generative AI leads marginally at 25.9%, but no 
single use case offers dramatically superior returns. The consulting recommendation: help clients focus on implementation 
quality rather than chasing the 'right' use case
*/


/*
  Does the ROI of a use case depend on which industry uses it?
  Looking for combinations that dramatically outperform the average (24.8%).
*/

SELECT 
  di.industry_name,
  duc.use_case_name,
  COUNT(*) AS companies,
  ROUND(AVG(f.ai_roi_percent)::numeric, 2) AS avg_roi
FROM fact_ai_adoption f
JOIN dim_industry di ON f.industry_id = di.industry_id
JOIN dim_use_case duc ON f.use_case_id = duc.use_case_id
JOIN dim_year dy ON f.year_id = dy.year_id
WHERE dy.year = 2025
  AND f.uses_ai_bool = TRUE
GROUP BY di.industry_name, duc.use_case_name
HAVING COUNT(*) >= 5
ORDER BY avg_roi DESC
LIMIT 15;

/* While overall ROI is uniform across use cases (~25%), industry-specific combinations reveal significant variation. Telecom 
companies using Demand Forecasting achieve 32.7% ROI — 8 points above average. Energy companies using Predictive Maintenance 
achieve 29.7%. This suggests the consulting recommendation should be industry-specific: don't recommend 'AI' generically, recommend
 the right use case for each sector.
 */

/*
  Does maturity level change which use cases deliver the best ROI?
  Splits companies into tiers then compares ROI by use case within each tier.
*/



SELECT 
  CASE 
    WHEN f.ai_maturity_score >= 80 THEN '1. Leader'
    WHEN f.ai_maturity_score >= 50 THEN '2. Adopter'
    ELSE '3. Laggard'
  END AS tier,
  duc.use_case_name,
  COUNT(*) AS companies,
  ROUND(AVG(f.ai_roi_percent)::numeric, 2) AS avg_roi
FROM fact_ai_adoption f
JOIN dim_use_case duc ON f.use_case_id = duc.use_case_id
JOIN dim_year dy ON f.year_id = dy.year_id
WHERE dy.year = 2025
  AND f.uses_ai_bool = TRUE
GROUP BY tier, duc.use_case_name
ORDER BY tier, avg_roi DESC;

/*AI use case ROI varies dramatically by company maturity. Leaders achieve 30.1% ROI from AI Trading but only 20.5% from Medical Imaging — 
a 10-point gap driven by use case selection. Laggards show the opposite pattern, gaining 27.2% from Medical Imaging but only 23.6% from 
Generative AI. This reveals two distinct consulting strategies: recommend 'easy win' applications (Medical Imaging, Recommendation Systems) to 
low-maturity clients for quick ROI, and recommend advanced applications (AI Trading, Generative AI) only to mature organisations that can extract value
from them.*/

/*
  ROI trend per use case from 2020 to 2025.
  Looking for use cases that are improving or declining.
*/

SELECT 
  duc.use_case_name,
  dy.year,
  COUNT(*) AS companies,
  ROUND(AVG(f.ai_roi_percent)::numeric, 2) AS avg_roi
FROM fact_ai_adoption f
JOIN dim_use_case duc ON f.use_case_id = duc.use_case_id
JOIN dim_year dy ON f.year_id = dy.year_id
WHERE f.uses_ai_bool = TRUE
GROUP BY duc.use_case_name, dy.year
ORDER BY duc.use_case_name, dy.year;

/*Generative AI is the only use case with consistently rising ROI (+2.8 points from 2020 to 2025), while first-wave applications like Chatbots (-2.7) and 
Customer Segmentation (-2.2) show declining returns. The consulting recommendation: position Generative AI as the growth opportunity for new clients, while 
helping existing Chatbot/Customer Segmentation users either optimise or migrate to higher-ROI applications*/