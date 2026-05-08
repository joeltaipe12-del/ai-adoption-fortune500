select  
COUNT(*) as total_rows,
COUNT(distinct company) as unique_company,
COUNT(distinct industry) as unique_industry, 
COUNT( distinct country) as unique_country,
MIN(year) as earliest_year,
MAX(year) as latest_year
from ai_adoption_raw aar; 


select year, count(*) as rows
from ai_adoption_raw aar 
group by year 
order by year; 

SELECT 
  COUNT(*) FILTER (WHERE year IS NULL) AS null_year,
  COUNT(*) FILTER (WHERE company IS NULL) AS null_company,
  COUNT(*) FILTER (WHERE industry IS NULL) AS null_industry,
  COUNT(*) FILTER (WHERE country IS NULL) AS null_country,
  COUNT(*) FILTER (WHERE company_type IS NULL) AS null_company_type,
  COUNT(*) FILTER (WHERE employee_size IS NULL) AS null_employee_size,
  COUNT(*) FILTER (WHERE revenue_usd IS NULL) AS null_revenue,
  COUNT(*) FILTER (WHERE uses_ai IS NULL) AS null_uses_ai,
  COUNT(*) FILTER (WHERE use_case IS NULL) AS null_use_case,
  COUNT(*) FILTER (WHERE ai_roi_percent IS NULL) AS null_roi,
  COUNT(*) FILTER (WHERE ai_maturity_score IS NULL) AS null_maturity
FROM ai_adoption_raw;

SELECT 
  uses_ai,
  COUNT(*) AS total,
  COUNT(*) FILTER (WHERE use_case = '') AS empty_strings,
  COUNT(*) FILTER (WHERE use_case IS NULL) AS true_nulls
FROM ai_adoption_raw
GROUP BY uses_ai;


SELECT use_case, COUNT(*) AS rows
FROM ai_adoption_raw
WHERE uses_ai = 'No'
GROUP BY use_case
ORDER BY COUNT(*) DESC;

SELECT company, year, COUNT(*) AS occurrences
FROM ai_adoption_raw
GROUP BY company, year
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

SELECT 
  MIN(revenue_usd) AS min_revenue,
  MAX(revenue_usd) AS max_revenue,
  ROUND(AVG(revenue_usd)::numeric, 2) AS avg_revenue,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY revenue_usd) AS median_revenue,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY revenue_usd) AS p95_revenue
FROM ai_adoption_raw;

SELECT industry, COUNT(*) AS rows
FROM ai_adoption_raw
GROUP BY industry
ORDER BY rows DESC;
 	
SELECT country, COUNT(*) FROM ai_adoption_raw GROUP BY country ORDER BY COUNT(*) DESC;
SELECT use_case, COUNT(*) FROM ai_adoption_raw GROUP BY use_case ORDER BY COUNT(*) DESC;
SELECT company_type, COUNT(*) FROM ai_adoption_raw GROUP BY company_type;
SELECT employee_size, COUNT(*) FROM ai_adoption_raw GROUP BY employee_size;

SELECT * FROM ai_adoption_raw ORDER BY RANDOM() LIMIT 10;

DROP VIEW IF EXISTS ai_adoption_clean;

CREATE VIEW ai_adoption_clean AS
SELECT
  year,
  company,
  industry,
  country,
  company_type,
  employee_size,
  revenue_usd,
  (uses_ai = 'Yes') AS uses_ai_bool,
  CASE 
    WHEN use_case = 'None' THEN 'Not adopted'
    ELSE use_case
  END AS use_case,
  ai_roi_percent,
  ai_maturity_score
FROM ai_adoption_raw;

SELECT * FROM ai_adoption_clean LIMIT 5;

drop table if exists dim_year CASCADE;  

create table dim_year as select
row_number() over (order by year) as year_id, year 
from (select distinct year from ai_adoption_clean) x;
alter table dim_year add primary key(year_id);

select * from dim_year
order by year_id

DROP TABLE IF EXISTS dim_company CASCADE;

CREATE TABLE dim_company AS
SELECT 
  ROW_NUMBER() OVER (ORDER BY company) AS company_id,
  company AS company_name,
  company_type
FROM (
  SELECT DISTINCT company, company_type 
  FROM ai_adoption_clean
) x;

ALTER TABLE dim_company ADD PRIMARY KEY (company_id);

DROP TABLE IF EXISTS dim_country CASCADE;

CREATE TABLE dim_country AS
SELECT 
  ROW_NUMBER() OVER (ORDER BY country) AS country_id,
  country AS country_name
FROM (
  SELECT DISTINCT country 
  FROM ai_adoption_clean
) x;

ALTER TABLE dim_country ADD PRIMARY KEY (country_id);


DROP TABLE IF EXISTS dim_industry CASCADE;

CREATE TABLE dim_industry AS
SELECT 
  ROW_NUMBER() OVER (ORDER BY industry) AS industry_id,
  industry AS industry_name
FROM (
  SELECT DISTINCT industry 
  FROM ai_adoption_clean
) x;

ALTER TABLE dim_industry ADD PRIMARY KEY (industry_id);

DROP TABLE IF EXISTS dim_use_case CASCADE;

CREATE TABLE dim_use_case AS
SELECT 
  ROW_NUMBER() OVER (ORDER BY use_case) AS use_case_id,
  use_case AS use_case_name
FROM (SELECT DISTINCT use_case FROM ai_adoption_clean) x;

ALTER TABLE dim_use_case ADD PRIMARY KEY (use_case_id);

DROP TABLE IF EXISTS fact_ai_adoption CASCADE;

CREATE TABLE fact_ai_adoption AS
SELECT 
  ROW_NUMBER() OVER (ORDER BY c.year, dco.company_name) AS fact_id,
  dy.year_id,
  dco.company_id,
  di.industry_id,
  dct.country_id,
  duc.use_case_id,
  c.employee_size,
  c.uses_ai_bool,
  c.revenue_usd,
  c.ai_roi_percent,
  c.ai_maturity_score
FROM ai_adoption_clean c
JOIN dim_year      dy  ON c.year      = dy.year
JOIN dim_company   dco ON c.company   = dco.company_name
JOIN dim_industry  di  ON c.industry  = di.industry_name
JOIN dim_country   dct ON c.country   = dct.country_name
JOIN dim_use_case  duc ON c.use_case  = duc.use_case_name;

ALTER TABLE fact_ai_adoption ADD PRIMARY KEY (fact_id);

select * from fact_ai_adoption
limit 15; 




