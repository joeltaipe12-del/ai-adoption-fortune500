# AI Adoption in the Fortune 500 (2020–2025)

A SQL + Tableau analysis of AI maturity across 1,000 Fortune 500 firms — identifying **$1.8T in addressable consulting opportunity** and a market that is bifurcating, not converging.

**Tech stack:** PostgreSQL · DBeaver · Tableau · Kaggle dataset

---

##Exective Summary 

- AI maturity in the Fortune 500 has plateaued at ~54.7 since 2020 despite an 81% adoption rate — **adoption is not advancement**.
- The market is bifurcating: **Amazon (+69)** and **JPMorgan (+51)** surged in 2024–2025; **Walmart (−27)**, **Google (−22)**, and **Tencent (−29)** regressed.
- Industry × use case drives **8+ ROI points** of variation.
- Generative AI ROI is rising; Chatbots are losing relevance.
- Seven Fortune 500 firms — **$1.8T combined revenue** — are below maturity benchmarks.
- **Walmart leads the target list** ($263B revenue, maturity 10).

---

## Project Workflow

End-to-end pipeline from raw CSV through PostgreSQL modelling to Tableau visualisation:

![Project Workflow Diagram](SQL%20project/Untitled.png)

---

## Deliverables

| File | What it is |
|---|---|
| `Docs/REPORT.docx` | 4-page consulting findings report |
| `Ai Adoption Dashboard .twb` | Three-page interactive Tableau workbook |
| `Dashboard/` | High-resolution dashboard screenshots (rendered below) |
| `04 Data exploration/` | Nine commented EDA queries with insights |
| `01_create_raw_table.sql` | Database setup and raw CSV ingestion |
| `All Data .sql` | Consolidated query script |
| `ai_adoption_tableau.csv` | Cleaned data export feeding the Tableau workbook |

---

## The Brief

A management consulting firm wants to identify which Fortune 500 industries and companies are the strongest candidates for AI consulting engagements over the next 12 months.

This project answers six business questions:

1. How has AI adoption grown across the Fortune 500 from 2020 to 2025?
2. Which industries lead and which lag in AI maturity?
3. Is there a relationship between AI investment and company revenue?
4. Which individual companies are the standout AI leaders?
5. Where is the biggest opportunity gap — high revenue, low maturity?
6. Which companies should the client prioritise for outreach?

---

## Dashboards

### Dashboard 1 — Overview
*"AI maturity in the Fortune 500 has plateaued"*

![Overview Dashboard](Overview%20new.png)

Surface-level trend analysis. Adoption rate, average maturity, leader/adopter/laggard tiers, and geographic distribution. The headline finding is the absence of growth despite continued adoption — the market has converted, but it hasn't matured.

### Dashboard 2 — Industry Deep Dive
*"Energy leads, Logistics lags — context drives AI value"*

![Industry Deep Dive Dashboard](SQL%20project/Dashboard/Industry%20Deep%20Dive.png)

Industry × use case ROI heatmap reveals the 8+ point spread invisible at either dimension alone. Logistics has 26.5% non-adoption — nearly double Energy's rate. Telecom × Demand Forecasting and Energy × Predictive Maintenance emerge as the highest-ROI cells in the matrix.

### Dashboard 3 — Opportunity Targets
*"AI maturity is splitting the Fortune 500"*

![Opportunity Targets Dashboard](SQL%20project/Dashboard/Opportunity%20Targets..png)

Quadrant analysis identifies seven verified Fortune 500 firms (combined revenue $1.8T) sitting materially below maturity benchmarks. Walmart anchors the target list at maturity 10 against a sector average of 54.5 — a textbook "high revenue × low maturity" consulting opportunity.

---

## SQL Methodology

The raw flat CSV was loaded into PostgreSQL and re-modelled into a star schema, then analysed with nine EDA queries. The work was structured in four phases.

### Hero queries

The three queries below are the analytical centrepieces of the project. Each combines a window function with a CTE pattern to answer a specific consulting question.

#### Q7 — Year-on-year growth per company (`LAG()` window function)

```sql
/*
Question: Which companies grew their AI maturity fastest from 2020 to 2025?
Insight:  Identifies "rising stars" — useful for case studies.
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
    JOIN dim_year dy   ON f.year_id    = dy.year_id
    WHERE dco.company_type = 'Real'
)
SELECT company_name, year, ai_maturity_score,
       ai_maturity_score - prev_year_score AS yoy_change
FROM   yearly_scores
WHERE  prev_year_score IS NOT NULL
ORDER  BY yoy_change DESC
LIMIT  10;
```

**Insight:** The biggest single-year jumps came from Infosys (+88), Shell (+78), and Amazon (+69) — Energy, Finance, and Technology dominate the rising-star list. Shell's 78-point jump in 2024 suggests Energy companies are making aggressive catch-up AI investments rather than gradual adoption.

#### Q8 — Top 3 most mature companies per industry (`RANK() OVER (PARTITION BY ...)`)

```sql
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
    JOIN dim_company dco ON f.company_id  = dco.company_id
    JOIN dim_year dy     ON f.year_id     = dy.year_id
    WHERE dy.year = 2025
      AND dco.company_type = 'Real'
)
SELECT industry_name, company_name, ai_maturity_score, revenue_usd, industry_rank
FROM   ranked
WHERE  industry_rank <= 3
ORDER  BY industry_name, industry_rank;
```

**Insight:** Industry leaders in 2025 include Procter & Gamble (100), Alibaba (98), Amazon (96), HSBC (94), and Infosys (94). Notably, Alibaba outscores Amazon in E-commerce maturity (98 vs 96), reflecting China's aggressive AI investment in online commerce.

#### Q9 — Opportunity gap: high revenue × low maturity (`PERCENT_RANK()` quartile-style scoring)

```sql
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
        PERCENT_RANK() OVER (ORDER BY f.revenue_usd DESC)        AS revenue_rank,
        PERCENT_RANK() OVER (ORDER BY f.ai_maturity_score ASC)   AS maturity_rank
    FROM fact_ai_adoption f
    JOIN dim_company  dco ON f.company_id  = dco.company_id
    JOIN dim_industry di  ON f.industry_id = di.industry_id
    JOIN dim_country  dct ON f.country_id  = dct.country_id
    JOIN dim_year     dy  ON f.year_id     = dy.year_id
    WHERE dy.year = 2025
      AND dco.company_type = 'Real'
)
SELECT company_name, industry_name, country_name,
       ROUND(revenue_usd::numeric, 0) AS revenue_usd,
       ai_maturity_score,
       ROUND((revenue_rank + maturity_rank)::numeric * 50, 1) AS opportunity_score
FROM   scored
ORDER  BY opportunity_score DESC
LIMIT  20;
```

**Insight:** Walmart is the standout target — $262B revenue, maturity score of just 10, the lowest of any major real company in the dataset. Other high-value targets: Shell ($367B / 71), Google ($328B / 74), Toyota ($291B / 76). The consulting recommendation: prioritise Walmart and the Retail sector, where AI maturity dramatically lags company scale.

---

## Project Phases

### Phase 1 — Database setup & raw load
Created a PostgreSQL database and loaded the raw Kaggle CSV (`ai_adoption_tableau.csv`) into a single staging table. Verified row count = 6,000.
*File: `01_create_raw_table.sql`*

### Phase 2 — Data quality & cleaning
Profiled the raw table for nulls, duplicates, and inconsistencies. Discovered the `company_type` flag distinguishing 20 verified Fortune 500 firms from synthetic placeholder records — a critical methodology insight that drove all downstream filtering.
*Folders: `01 Data Checks ai_adoption/`, `02 Data Checks ai_adoption/`, `03 Data Clean view/`*

### Phase 3 — Star schema build
Re-modelled the flat staging table into a dimensional model: one fact table joined to five dimensions (`dim_company`, `dim_industry`, `dim_country`, `dim_year`, `dim_use_case`). This enabled cleaner aggregations and simpler downstream analysis.

```
fact_ai_adoption
├── company_id   → dim_company   (name, company_type, employee_size)
├── industry_id  → dim_industry  (industry_name)
├── country_id   → dim_country   (country_name)
├── year_id      → dim_year      (year)
└── use_case_id  → dim_use_case  (use_case_name)
```

*File: `All Data .sql`*

### Phase 4 — Exploratory analysis (9 queries)
Nine numbered SQL files, each addressing one of the business questions, with a comment header explaining the question and the insight.

| # | Query | Technique |
|---|-------|-----------|
| 01 | Maturity over time | `GROUP BY` aggregation |
| 02 | Top industries 2025 | `JOIN` + ordered aggregation |
| 03 | Adoption rate per year | `CASE WHEN` boolean count |
| 04 | Maturity tiers (Leader / Adopter / Laggard) | `CASE WHEN` bucketing |
| 05 | ROI by use case | Conditional aggregates |
| 06 | Enterprise vs SME comparison | Cross-tab segmentation |
| 07 | Year-on-year growth per company | `LAG()` window function |
| 08 | Top 3 companies per industry | `RANK() OVER (PARTITION BY)` |
| 09 | Opportunity gap — high revenue × low maturity | `PERCENT_RANK()` scoring |

*Folder: `04 Data exploration/`*

---

## Key Findings

### 1. The plateau
Average maturity has remained flat at 53.6–55.0 across the six-year window. Adoption rate has held at ~81%. But the tier distribution reveals a polarised market: **11.5% Leaders, 52% Adopters, 36.5% Laggards**. The plateau in averages masks widening internal dispersion.

### 2. Industry × use case drives ROI
Cross-tabbing industry against use case surfaces an 8+ percentage-point ROI spread invisible at either dimension alone. **Telecom × Demand Forecasting** delivers 32.7% ROI vs a 25% market average. **Logistics × Chatbots** delivers only 20.3%. Generative AI is the only use case with a positive ROI trajectory; Chatbot ROI is regressing.

### 3. The bifurcation
Year-on-year change reveals the most counter-intuitive finding: a small accelerating cohort (Amazon +69, JPMorgan +51) and a much larger regressing one (Walmart −27, Google −22, Tencent −29). The thesis of natural maturity convergence is rejected by the data.

### 4. The opportunity list
A composite filter — revenue > $50B, maturity < 78, verified firm, 2025 — identifies seven target companies representing $1.8T in combined revenue, anchored by Walmart ($263B / maturity 10 / 0% AI ROI).

---

## Challenges & Methodology Decisions

Several methodology decisions emerged during the analysis. Each is documented because the way they were resolved is itself a transferable skill.

1. **Real vs synthetic companies.** Early queries returned unrecognisable company names. Inspection of the `company_type` field revealed the dataset mixes 20 verified Fortune 500 firms with synthetic placeholder records. *Decision:* filter to `company_type = 'Real'` for all named-company analysis; retain the full panel for industry-level aggregates where statistical robustness matters more than recognisability.

2. **Window function aggregation errors.** Initial year-on-year change queries using `LAG()` produced "all fields must aggregate or constant" errors when joined to other measures. *Decision:* wrap the `LAG()` in a CTE to produce a clean derived column, then aggregate downstream. The CTE pattern became the template for all subsequent window-function queries.

3. **Quartile filtering returning the wrong companies.** The first opportunity gap query ranked Amazon as a top "target" — but Amazon is already an AI leader, not a target. Inspection showed the synthetic data was distorting quartile boundaries. *Decision:* scope the percentile calculation inside a CTE filtered to real companies only, ensuring quartiles reflect the verified peer group.

4. **Single-firm industries in the verified sample.** Retail = Walmart only; Industrial = Siemens only. Cross-industry comparison is unreliable for these sectors. *Decision:* flag these caveats in the report and treat sector findings for Retail and Industrial as directional rather than statistical.

5. **Tableau LOD vs sheet-filter conflicts.** Year-on-year metrics built with simple LOOKUP table calculations broke when dashboard-level filters were applied. *Decision:* rewrite using `{FIXED [Company]: ...}` LOD expressions with the real-company filter embedded, ensuring per-company integrity is preserved across all visualisations.

6. **Year-on-year swings exceeding 50 maturity points.** Amazon's +69 jump in 2025 exceeds plausible real-world rates of organisational change. *Decision:* flag as a likely dataset-construction artefact in the report, but retain the relative ranking — Amazon and JPMorgan as risers, Walmart and Tencent as fallers — because the bifurcation finding holds regardless of absolute magnitude.

---

## Repository Structure

```
ai-adoption-fortune500/
├── README.md
├── LICENSE
├── Overview new.png             ← updated overview dashboard
└── SQL project/
    ├── 01_create_raw_table.sql       ← raw CSV ingestion
    ├── All Data .sql                  ← consolidated query script
    ├── ai_adoption_tableau.csv        ← cleaned export feeding Tableau
    ├── Ai Adoption Dashboard .twb     ← Tableau workbook
    ├── Untitled.png                   ← project workflow diagram
    ├── 01 Data Checks ai_adoption/    ← initial data profiling
    ├── 02 Data Checks ai_adoption/    ← extended data profiling
    ├── 03 Data Clean view/            ← cleaned views
    ├── 04 Data exploration/           ← 9 EDA queries (numbered)
    ├── Dashboard/                     ← high-resolution screenshots
    │   ├── Industry Deep Dive.png
    │   └── Opportunity Targets..png
    └── Docs/                          ← findings report
```

---

## Skills Demonstrated

- **Data modelling** — Designed a star schema from a flat CSV (1 fact + 5 dimensions). Most junior portfolios skip this; it is the highest-leverage skill on this repo.
- **Advanced SQL** — CTEs, `LAG()`, `RANK() OVER (PARTITION BY)`, `PERCENT_RANK()` window functions, and conditional aggregation.
- **Dashboard design** — Three Tableau dashboards using insight-led titles, restrained colour palettes, and clear KPI hierarchies.
- **Business framing** — A consulting scenario with six explicit business questions, four strategic recommendations, and a tiered outreach list.
- **Methodological honesty** — Synthetic-data filtering, single-firm industry caveats, and explicit framing of dataset limitations.

---

*Source: Kaggle — AI Adoption in Fortune 500 Companies (2020–2025) synthetic dataset.*
