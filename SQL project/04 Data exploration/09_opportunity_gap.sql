/*
  Opportunity gap for real companies.
  Uses a scoring approach instead of strict quartile filtering.
  Higher opportunity_score = more revenue + less maturity = better target.
*/

WITH scored AS (
  SELECT 
    dco.company_name,
    di.industry_name,
    dct.country_name,
    f.revenue_usd,
    f.ai_maturity_score,
    PERCENT_RANK() OVER (ORDER BY f.revenue_usd DESC) AS revenue_rank,
    PERCENT_RANK() OVER (ORDER BY f.ai_maturity_score ASC) AS maturity_rank
  FROM fact_ai_adoption f
  JOIN dim_company dco ON f.company_id = dco.company_id
  JOIN dim_industry di ON f.industry_id = di.industry_id
  JOIN dim_country dct ON f.country_id = dct.country_id
  JOIN dim_year dy ON f.year_id = dy.year_id
  WHERE dy.year = 2025
    AND dco.company_type = 'Real'
)
SELECT 
  company_name,
  industry_name,
  country_name,
  ROUND(revenue_usd::numeric, 0) AS revenue_usd,
  ai_maturity_score,
  ROUND((revenue_rank + maturity_rank)::numeric * 50, 1) AS opportunity_score
FROM scored
ORDER BY opportunity_score DESC
LIMIT 20;

The opportunity gap analysis identified Walmart as the standout target: $262B in revenue but 
an AI maturity score of just 10 — the lowest of any major real company in the dataset. Other
high-value targets include Shell ($367B, maturity 71), Google ($328B, maturity 74), and Toyota 
($291B, maturity 76). The consulting recommendation: prioritise Walmart and Retail sector engagement, 
where AI maturity dramatically lags company scale.