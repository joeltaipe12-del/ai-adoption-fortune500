/*
  Question: What % of Fortune 500 companies are using AI each year?
  Insight: Adoption rate vs maturity tells different stories — adoption can plateau while maturity keeps growing.
*/


SELECT 
  dy.year,
  COUNT(*) AS total_companies,
  SUM(CASE WHEN f.uses_ai_bool THEN 1 ELSE 0 END) AS ai_users,
  ROUND(
    100.0 * SUM(CASE WHEN f.uses_ai_bool THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS adoption_rate_pct
FROM fact_ai_adoption f
JOIN dim_year dy ON f.year_id = dy.year_id
GROUP BY dy.year
ORDER BY dy.year;

/* AI adoption among the Fortune 500 has plateaued at approximately 81% since 2020,
with no meaningful growth in either adoption rate or maturity scores. This suggests 
two distinct consulting opportunities: (1) the ~190 non-adopters who need first-time
implementation, and (2) the ~810 current users whose maturity has stagnated and who need 
optimisation and upskilling. 
/*

SELECT 
  di.industry_name,
  COUNT(*) AS total,
  SUM(CASE WHEN f.uses_ai_bool THEN 1 ELSE 0 END) AS ai_users,
  SUM(CASE WHEN NOT f.uses_ai_bool THEN 1 ELSE 0 END) AS non_adopters,
  ROUND(
    100.0 * SUM(CASE WHEN NOT f.uses_ai_bool THEN 1 ELSE 0 END) / COUNT(*),
    1
  ) AS non_adoption_pct
FROM fact_ai_adoption f
JOIN dim_industry di ON f.industry_id = di.industry_id
JOIN dim_year dy ON f.year_id = dy.year_id
WHERE dy.year = 2025
GROUP BY di.industry_name
HAVING COUNT(*) >= 30
ORDER BY non_adoption_pct DESC;

This is excellent — now you can see exactly where the non-adopters are hiding.
The standout findings:
Logistics is the laggard. 26.5% non-adoption — more than 1 in 4 logistics companies 
aren't using AI at all. That's nearly double Energy's rate (15.3%). For a consulting client,
this is a goldmine: logistics companies have massive operational data (routes, warehouses, deliveries) 
that AI could optimise, but a quarter of them haven't even started.
E-commerce at 21.9% is surprising. You'd expect online-first companies to be early adopters, yet nearly 
1 in 5 aren't using AI. These might be smaller e-commerce players who sell through third-party platforms 
and haven't invested in their own AI capabilities.
Energy leads again. Lowest non-adoption at 15.3%, and we already know from Query 2 that Energy also has 
the highest maturity score (57.38). Energy is the clear AI leader in this dataset — both in breadth of adoption 
and depth of maturity.
The spread tells a story:
TierIndustriesNon-adoptionHighest non-adoptionLogistics, E-commerce, Retail20-27%MiddleTechnology, Telecom, 
Healthcare18-19%Lowest non-adoptionFinance, Manufacturing, Energy15-17%
There's a clear pattern: traditional, operationally-heavy industries (Energy, Manufacturing, Finance) 
have embraced AI more than customer-facing, fast-moving ones (Logistics, E-commerce, Retail). That's counter-intuitive 
and worth highlighting.
Write this down for your report:

"Logistics has the highest AI non-adoption rate at 26.5%, followed by E-commerce (21.9%) and Retail (19.6%). 
Conversely, Energy (15.3%) and Manufacturing (15.5%) show the strongest adoption. This suggests operationally 
complex industries — where AI can directly reduce costs — adopt faster than customer-facing sectors. For the 
consulting client, the 27 non-adopting Logistics companies and 23 non-adopting E-commerce companies represent 
the most concentrated outreach opportunity.