- Question: How has average AI maturity score evolved from 2020 to 2025?

select 
	dy.year, 
	round(AVG(f.ai_maturity_score)::numeric,2) as avg_maturity_score, 
	count(*) as company_count
from fact_ai_adoption f
join dim_year dy  on f.year_id = dy.year_id
group by dy.year
order by dy.year;

- Average AI maturity across the Fortune 500 remained flat at approximately 54-55 from 2020 to 2025,
suggesting that while new companies may be adopting AI, overall maturity is not improving — the market 
is wide open for consulting.