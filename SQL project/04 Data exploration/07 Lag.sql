/*
  Question: Which companies grew their AI maturity fastest from 2020 to 2025?
  Insight: Identifies "rising stars" — useful for case studies.
  
  Technique: window function LAG() to compare each year to the previous.
*/

WITH yearly_scores AS (
  SELECT 
    dco.company_name,
    dy.year,
    f.ai_maturity_score,
    LAG(f.ai_maturity_score) OVER (
      PARTITION BY dco.company_name 
      ORDER BY dy.year
    ) AS prev_year_score
  FROM fact_ai_adoption f
  JOIN dim_company dco ON f.company_id = dco.company_id
  JOIN dim_year dy ON f.year_id = dy.year_id
  WHERE dco.company_type = 'Real'
)
SELECT 
  company_name,
  year,
  ai_maturity_score,
  ai_maturity_score - prev_year_score AS yoy_change
FROM yearly_scores
WHERE prev_year_score IS NOT NULL
ORDER BY yoy_change DESC
LIMIT 10;

The biggest single-year AI maturity jumps came from Infosys (+88), Shell (+78), 
and Amazon (+69). The rising star list is dominated by Energy, Finance, and Technology 
companies — reinforcing the industry-level patterns identified earlier. Notable: Shell's 
78-point jump in 2024 suggests Energy companies are making aggressive, catch-up AI investments 
rather than gradual adoption.


lag this as likely influenced by the synthetic nature of the dataset. Real maturity scores don't 
typically swing this dramatically — but the relative ranking of which companies jumped most is still analytically useful.
