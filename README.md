# Project Charter: Premier League Style Evolution (2021–2025)

## **Goal**
Build an end-to-end analytics project (SQL + Tableau) to analyze how team playing styles evolved across four Premier League seasons, including a clustering-based segmentation of styles.

---

## **Business Questions**
* **How did the league’s average style change** from 2021 to 2025 (control, pressing, directness, threat)?
* **What style segments (clusters) exist** each season and how does the mix change over time?
* **Which teams are the most consistent** vs the most volatile in style across seasons?
* **How does each team compare** to the league benchmarks (percentiles) in a given season?

---

## **Deliverables**
* Cleaned and enriched datasets (team × match) for 4 seasons
* SQL data model + views for Tableau
* **Tableau dashboard (4 pages):** League Evolution, Style Segments, Team Benchmark, Trends
* Clustering output (team × season cluster labels + signatures)
* README + data dictionary + final insights + slides

---

## **Scope**
* **Competition:** Premier League
* **Seasons:** 2021–22, 2022–23, 2023–24, 2024–25
* **Granularity:** team × match (760 rows per season)
* **Tools:** Python (ETL/analysis), SQL (data modeling), Tableau (dashboard)