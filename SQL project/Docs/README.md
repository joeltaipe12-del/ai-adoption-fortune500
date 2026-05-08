# AI Adoption in the Fortune 500 (2020–2025)

> A SQL + Tableau analysis of AI maturity across 1,000 Fortune 500 firms — identifying **$1.8T in addressable consulting opportunity** and a market that is bifurcating, not converging.

**Tech stack:** PostgreSQL · DBeaver · Tableau Public · Kaggle dataset

---

## TL;DR

- AI maturity in the Fortune 500 has **plateaued at ~54.7 since 2020** despite an 81% adoption rate — adoption is not advancement.
- The market is **bifurcating**: Amazon (+69) and JPMorgan (+51) surged in 2024–2025; Walmart (−27), Google (−22), and Tencent (−29) regressed.
- **Industry × use case** drives 8+ ROI points of variation. Generative AI ROI is rising; Chatbots are losing relevance.
- **Seven Fortune 500 firms — $1.8T combined revenue — are below maturity benchmarks.** Walmart leads the target list ($263B revenue, maturity 10).

---

## Deliverables

| File | What it is |
|------|-----------|
| `docs/REPORT.docx` | 4-page consulting-style findings report |
| `dashboard/ai_adoption.twbx` | Three-page interactive Tableau workbook |
| `dashboard/screenshots/` | High-resolution dashboard images (rendered below) |
| `sql/04_exploration/*.sql` | Nine commented EDA queries with insights |
| `docs/erd_diagram.png` | Star schema diagram |

---

## The Brief

A management consulting firm wants to identify which Fortune 500 industries and companies are the strongest candidates for AI consulting engagements over the next 12 months. This project answers six business questions:

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

![Dashboard 1 – Overview](dashboard/screenshots/01_overview.png)

Surface-level trend analysis. Adoption rate, average maturity, leader/adopter/laggard tiers, and geographic distribution. The headline finding is the absence of growth despite continued adoption.

### Dashboard 2 — Industry Deep Dive
*"Energy leads, Logistics lags — context drives AI value"*

![Dashboard 2 – Industry Deep Dive](dashboard/screenshots/02_industry_deep_dive.png)

Industry × use case ROI heatmap reveals the 8+ point spread invisible at either dimension alone. Logistics has 26.5% non-adoption — nearly double Energy's rate.

### Dashboard 3 — Opportunity Targets
*"AI maturity is splitting the Fortune 500"*

![Dashboard 3 – Opportunity Targets](dashboard/screenshots/03_opportunity_targets.png)

Quadrant analysis identifies seven verified Fortune 500 firms (combined revenue $1.8T) sitting materially below maturity benchmarks. Walmart anchors the target list at maturity 10 against a sector average of 54.5.

---

## SQL Methodology

The raw flat CSV was loaded into PostgreSQL and re-modelled into a star schema, then analysed with nine EDA queries. The work was structured in four phases.

<details>
<summary><b>Phase 1 — Database setup &amp; raw load</b></summary>

Installed PostgreSQL 16 locally. Created the `ai_adoption` database, then loaded the raw CSV into a single staging table (`ai_adoption_raw`) using `COPY ... FROM 'path.csv' DELIMITER ',' CSV HEADER`. Verified row count = 6,000.

**Files:** `sql/01_setup/01_create_database.sql`, `sql/01_setup/02_create_staging_table.sql`, `sql/01_setup/03_copy_csv.sql`

</details>

<details>
<summary><b>Phase 2 — Data quality &amp; cleaning</b></summary>

Profiled the raw table for nulls, duplicates, and inconsistencies. Discovered the `company_type` flag distinguishing 20 verified Fortune 500 firms from synthetic placeholder records — a critical methodology insight that drove all downstream filtering.

**Files:** `sql/02_cleaning/01_null_check.sql`, `sql/02_cleaning/02_duplicate_check.sql`, `sql/02_cleaning/03_outlier_check.sql`, `sql/02_cleaning/04_clean_view.sql`

</details>

<details>
<summary><b>Phase 3 — Star schema build</b></summary>

Re-modelled the flat staging table into a dimensional model: one fact table (`fact_ai_adoption`) joined to five dimensions (`dim_company`, `dim_industry`, `dim_country`, `dim_year`, `dim_use_case`). This enabled cleaner aggregations and simpler downstream analysis.

```
fact_ai_adoption
├── company_id   → dim_company   (name, company_type, employee_size)
├── industry_id  → dim_industry  (industry_name)
├── country_id   → dim_country   (country_name)
├── year_id      → dim_year      (year)
└── use_case_id  → dim_use_case  (use_case_name)
```

**Files:** `sql/03_star_schema/01_create_dimensions.sql`, `sql/03_star_schema/02_populate_dimensions.sql`, `sql/03_star_schema/03_create_fact.sql`, `sql/03_star_schema/04_populate_fact.sql`

</details>

<details>
<summary><b>Phase 4 — Exploratory analysis (9 queries)</b></summary>

Nine numbered SQL files, each addressing one of the business questions, with a comment header explaining the question and the insight.

| # | Query | Technique |
|---|-------|-----------|
| 01 | Maturity over time | `GROUP BY` aggregation |
| 02 | Top industries 2025 | `JOIN` + ordered aggregation |
| 03 | Adoption rate per year | `CASE WHEN` boolean count |
| 04 | Maturity tiers (Leader/Adopter/Laggard) | `CASE WHEN` bucketing |
| 05 | Industry non-adoption % | Conditional aggregates |
| 06 | Enterprise vs SME comparison | Cross-tab segmentation |
| 07 | Year-on-year growth per company | **`LAG()` window function** |
| 08 | Top 3 companies per industry | **`RANK() OVER (PARTITION BY)`** |
| 09 | Opportunity gap — high revenue × low maturity | **`NTILE(4)` quartile filter** |

**Files:** `sql/04_exploration/01_maturity_over_time.sql` … `09_opportunity_gap.sql`

</details>

---

## Key Findings

### 1. The plateau

Average maturity has remained flat at 53.6–55.0 across the six-year window. Adoption rate has held at ~81%. But the tier distribution reveals a polarised market: 11.5% Leaders, 52% Adopters, 36.5% Laggards. The plateau in averages masks widening internal dispersion.

### 2. Industry × use case drives ROI

Cross-tabbing industry against use case surfaces an 8+ percentage-point ROI spread invisible at either dimension alone. **Telecom × Demand Forecasting** delivers 32.7% ROI vs a 25% market average. **Logistics × Chatbots** delivers 20.3%. Generative AI is the only use case with a positive ROI trajectory; Chatbot ROI is regressing.

### 3. The bifurcation

Year-on-year change reveals the most counter-intuitive finding: a small accelerating cohort (Amazon +69, JPMorgan +51) and a much larger regressing one (Walmart −27, Google −22, Tencent −29). The thesis of natural maturity convergence is rejected by the data.

A composite filter — revenue > $50B, maturity < 78, verified firm, 2025 — identifies seven target companies representing $1.8T in combined revenue, anchored by Walmart ($263B / maturity 10 / 0% AI ROI).

---

## Challenges &amp; Methodology Decisions

Several methodology decisions emerged during the analysis. Each is documented because the way they were resolved is itself a transferable skill.

**1. Real vs synthetic companies**
Early queries returned unrecognisable company names. Inspection of the `company_type` field revealed the dataset mixes 20 verified Fortune 500 firms with synthetic placeholder records. **Decision:** filter to `company_type = 'Real'` for all named-company analysis; retain the full panel for industry-level aggregates where statistical robustness matters more than recognisability.

**2. Window function aggregation errors**
Initial year-on-year change queries using `LAG()` produced "all fields must aggregate or constant" errors when joined to other measures. **Decision:** wrap the `LAG()` in a CTE to produce a clean derived column, then aggregate downstream. The CTE pattern became the template for all subsequent window-function queries.

**3. NTILE quartile filtering returning the wrong companies**
The first opportunity gap query ranked Amazon as a top "target" — but Amazon is already an AI leader, not a target. Inspection showed the synthetic data was distorting quartile boundaries. **Decision:** scope the `NTILE` calculation inside a CTE filtered to real companies only, ensuring quartiles reflect the verified peer group.

**4. Single-firm industries in the verified sample**
Retail = Walmart only; Industrial = Siemens only. Cross-industry comparison is unreliable for these sectors. **Decision:** flag these caveats in the report and treat sector findings for Retail and Industrial as directional rather than statistical.

**5. Tableau LOD vs sheet-filter conflicts**
Year-on-year metrics built with simple LOOKUP table calculations broke when dashboard-level filters were applied. **Decision:** rewrite using `{FIXED [Company]: ...}` LOD expressions with the real-company filter embedded, ensuring per-company integrity is preserved across all visualisations.

**6. Year-on-year swings exceeding 50 maturity points**
Amazon's +69 jump in 2025 exceeds plausible real-world rates of organisational change. **Decision:** flag as a likely dataset-construction artefact in the report, but retain the *relative* ranking — Amazon and JPMorgan as risers, Walmart and Tencent as fallers — because the bifurcation finding holds regardless of absolute magnitude.

---

## Repository Structure

```
ai-adoption-fortune500/
├── README.md
├── sql/
│   ├── 01_setup/                ← database creation, CSV load
│   ├── 02_cleaning/             ← data quality checks
│   ├── 03_star_schema/          ← dimensional model build
│   └── 04_exploration/          ← 9 EDA queries (numbered)
├── dashboard/
│   ├── ai_adoption.twbx         ← Tableau workbook
│   └── screenshots/
│       ├── 01_overview.png
│       ├── 02_industry_deep_dive.png
│       └── 03_opportunity_targets.png
└── docs/
    ├── REPORT.docx              ← 4-page findings report
    ├── REPORT.md                ← Markdown version
    └── erd_diagram.png          ← star schema diagram
```

---

## Skills Demonstrated

- **Data modelling.** Designed a star schema from a flat CSV (1 fact + 5 dimensions). Most junior portfolios skip this — it's the highest-leverage skill on this repo.
- **Advanced SQL.** CTEs, `LAG()`, `RANK() OVER (PARTITION BY)`, `NTILE()` window functions, and conditional aggregation.
- **Dashboard design.** Three Tableau dashboards using McKinsey-style insight titles, restrained colour palettes, and BAN-led KPI rows.
- **Business framing.** A consulting scenario with six explicit business questions, four strategic recommendations, and a tiered outreach list.
- **Methodological honesty.** Synthetic-data filtering, single-firm industry caveats, and explicit framing of dataset limitations.

---

## Author

**Joel Taipe** — BSc Economics, Loughborough University. Job-seeking in finance and data analytics.

This project was built to demonstrate end-to-end analytical capability: data ingestion, modelling, querying, visualisation, and consulting-style communication. The synthetic dataset is illustrative rather than predictive — but the methodology and strategic logic transfer to real-world data.

---

*Source: Kaggle — [AI Adoption in Fortune 500 Companies (2020–2025)](https://www.kaggle.com/datasets/abidhussai512/ai-adoption-in-fortune-500-companies-20202025) synthetic dataset.*
