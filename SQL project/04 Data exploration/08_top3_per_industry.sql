/*
  Top 3 most mature real companies per industry in 2025.
  Technique: RANK() with PARTITION BY.
*/

WITH ranked AS (
  SELECT 
    di.industry_name,
    dco.company_name,
    f.ai_maturity_score,
    f.revenue_usd,
    RANK() OVER (
      PARTITION BY di.industry_name 
      ORDER BY f.ai_maturity_score DESC
    ) AS industry_rank
  FROM fact_ai_adoption f
  JOIN dim_industry di ON f.industry_id = di.industry_id
  JOIN dim_company dco ON f.company_id = dco.company_id
  JOIN dim_year dy ON f.year_id = dy.year_id
  WHERE dy.year = 2025
    AND dco.company_type = 'Real'
)
SELECT 
  industry_name,
  company_name,
  ai_maturity_score,
  revenue_usd,
  industry_rank
FROM ranked
WHERE industry_rank <= 3
ORDER BY industry_name, industry_rank;

Industry AI leaders in 2025 include Procter & Gamble (100), Alibaba (98), Amazon (96), HSBC (94), and Infosys (94).
Technology and Finance show the deepest bench of mature companies, while Retail and Industrial have too few real companies
in the dataset for reliable comparison. Notable: Alibaba outscores Amazon in E-commerce maturity (98 vs 96), reflecting China's 
aggressive AI investment in online commerce.

