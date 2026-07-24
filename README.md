# 🛵 Q-Commerce Delivery Operations & Pricing Analytics

**A benchmarking analysis across 8 quick-commerce platforms — Blinkit, Zepto, Swiggy Instamart, and 5 others — built to answer: who's operationally efficient, who's leaving money on the table with discounts, and where should these platforms invest next?**

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-150458?style=for-the-badge&logo=pandas&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)

---

### 📌 Quick Stats

| Metric | Value |
|---|---|
| Orders analyzed | 1,000,000 |
| Platforms compared | 8 (Blinkit, Zepto, Swiggy Instamart, Amazon Now, Big Basket, Dunzo, Flipkart Minutes, Jio Mart) |
| Cities covered | 12 |
| Product categories | 7 |
| Fastest platform | Zepto — 8.8 min median delivery |
| Discount rate spread | 30.8% → 65.7% by order-value quartile |

---

## 📑 Table of Contents

1. [Problem Statement](#1-problem-statement)
2. [Data Source & Cleaning](#2-data-source--cleaning)
3. [Data Modeling — Star Schema](#3-data-modeling--star-schema)
4. [SQL Analysis — Window Functions](#4-sql-analysis--window-functions)
5. [Key Findings](#5-key-findings)
6. [Dashboard](#6-dashboard)
7. [Repository Structure](#7-repository-structure)
8. [Tools Used](#8-tools-used)

---

## 1. Problem Statement

Quick-commerce platforms compete on a narrow set of levers: delivery speed, pricing, and customer experience. This project simulates the kind of ops/strategy analysis a business analyst at one of these companies would run — using a 1-million-order synthetic dataset spanning 8 platforms, 12 Indian cities, and 7 product categories — to answer three concrete business questions:

1. Which platforms are operationally fastest, and by how much?
2. Are there cities where delivery infrastructure is under-serving demand?
3. Does discounting behavior make sense — is it driven by product category, or by something else?

---

## 2. Data Source & Cleaning

**Source**: Synthetic quick-commerce order dataset, 1,000,000 rows, 13 columns (Order ID, Company, City, Customer Age, Order Value, Delivery Time, Distance, Items Count, Product Category, Payment Method, Customer Rating, Discount Applied, Delivery Partner Rating).

**Cleaning decisions** (Python/Pandas):

| Issue | Treatment | Reasoning |
|---|---|---|
| City — 5.2% null | Labelled `"Unknown"` | Geography can't be reliably inferred from other fields; imputing would fabricate data. Rows are kept for non-city analyses and excluded from city-specific ones. |
| Items_Count — 3.5% null | Imputed with category-level median | A count field; a low-bias, defensible fill. |
| Customer_Rating — 4.7% null | **Left as NULL** | Imputing a rating would bias any rating-based analysis (e.g. delivery time vs. satisfaction). SQL/DAX aggregate functions correctly skip NULLs. |
| Delivery_Partner_Rating — 10.4% null | **Left as NULL** | Same reasoning as above. |
| "Bengluru" typo | Corrected to "Bengaluru" | Data quality fix. |

> No duplicate Order IDs were found, and all numeric ranges were sane (no outlier clipping needed) — this is a well-bounded synthetic dataset.

---

## 3. Data Modeling — Star Schema

Rather than working off one flat table, the cleaned data was loaded into **PostgreSQL** using a star schema: one central fact table plus three small dimension tables.

```
        dim_company              dim_city
        (company_id, name)       (city_id, name)
              \                       /
               \                     /
                fact_orders
        (order_id, company_id, city_id, category_id,
         customer_age, order_value, delivery_time_min, ...)
                     /
                    /
           dim_category
           (category_id, name)
```

This mirrors how real retail/BFSI data warehouses are structured, keeps the fact table lean, and makes the relational model transfer cleanly into Power BI (which auto-detected all three relationships from the foreign keys on import).

**Pipeline**: raw CSV → staging table → dimension tables populated via `INSERT ... SELECT DISTINCT` → fact table populated via a 3-way `JOIN` converting text labels to surrogate IDs.

---

## 4. SQL Analysis — Window Functions

Five techniques were used to answer the business questions directly in SQL before any visualization:

**`PERCENTILE_CONT`** — median and P90 delivery time per platform, more robust than `MAX()` since it ignores one-off outliers while still capturing "typical worst-case" performance.

```sql
SELECT
    c.company_name,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY f.delivery_time_min) AS median_delivery_time,
    PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY f.delivery_time_min) AS p90_delivery_time
FROM fact_orders f
JOIN dim_company c ON f.company_id = c.company_id
GROUP BY c.company_name;
```

**`RANK() OVER (ORDER BY ...)`** — ranked platforms by average order value, a true window function that ranks aggregated results without collapsing them further.

**`AVG() OVER (PARTITION BY ...)`** — compared every individual order against its own platform's average, without collapsing 1M rows into 8 summary rows — the key distinction from `GROUP BY`.

**`NTILE(4)` inside a CTE** — split all 1M orders into value quartiles to test discount elasticity. Window functions can't be referenced directly inside the same query's `GROUP BY`, so this required staging the `NTILE()` result in a CTE first, then aggregating in a second step.

**`CASE WHEN` bucketing** — grouped orders into delivery-time bands to test the relationship between speed and customer rating.

---

## 5. Key Findings

> **Finding 1 — Speed varies 2.5x across platforms, but satisfaction barely moves.**
> Zepto is fastest (8.8 min median delivery), Jio Mart slowest (22.9 min) — yet average customer rating only drops from 3.12 to 2.95 across that entire range. Delivery speed is not the dominant driver of customer satisfaction in this data; something else (product quality, app experience, order accuracy) likely matters more.

> **Finding 2 — Haridwar has metro-level demand but tier-3 delivery infrastructure.**
> Haridwar (27.7 min median delivery) and Delhi (5.6 min) have nearly identical order volumes (78,958 vs. 79,183 — a 0.3% difference), ruling out a demand gap. The delivery-time disparity points to an operational capacity gap: fewer dark stores or less efficient routing relative to the demand Haridwar actually receives — not lower demand itself.

> **Finding 3 — Discounting is driven by order value, not product category.**
> Discount rate is essentially flat across all 7 product categories (~40% each). But split by order-value quartile, it climbs sharply: 30.8% for the cheapest quartile up to 65.7% for the priciest quartile (orders above ₹796). Platforms are discounting their highest-value orders more aggressively — the opposite of a "nudge hesitant small orders to convert" strategy.

---

## 6. Dashboard

Built in Power BI, 3 pages, connected live to the PostgreSQL star schema via Import mode.

### Platform Benchmarking
*Full metric table, AOV ranking, and a speed-vs-value scatter plot across all 8 platforms*

<img width="1424" height="799" alt="Platform Benchmarking Dashboard" src="https://github.com/user-attachments/assets/b1a2ca8b-9303-4d5d-8947-18c948b903fb" />

### City Performance
*Sortable city scorecard (orders, AOV, delivery time, P90, discount rate) plus a category-by-city matrix*

<img width="1421" height="794" alt="City Performance Dashboard" src="https://github.com/user-attachments/assets/66580d2e-b168-4d67-9282-49ebcd9f67e0" />

### Discount & Pricing
*Category vs. quartile discount comparison, plus a per-platform discount breakdown*

<img width="1427" height="802" alt="Discount and Pricing Dashboard" src="https://github.com/user-attachments/assets/9be0ffc6-1fc0-4300-b5a3-85a77725c494" />

---

## 7. Repository Structure

```
Quick-Commerce-Delivery-Analytics/
├── README.md
├── data/
│   └── quick_commerce_data_cleaned.csv
├── python/
│   └── 01_data_cleaning.py
├── sql/
│   ├── 02_create_schema.sql
│   ├── 03_create_staging.sql
│   ├── 04_populate_dims.sql
│   ├── 05_populate_fact.sql
│   ├── 06_percentile_analysis.sql
│   ├── 07_rank_aov.sql
│   ├── 08_partition_by.sql
│   ├── 09_ntile_quartiles.sql
│   └── 10_delivery_vs_rating.sql
├── powerbi/
│   └── qcommerce_theme_dark.json
└── images/
```

---

## 8. Tools Used

| Tool | Purpose |
|---|---|
| **Python (Pandas)** | Data cleaning |
| **PostgreSQL** | Star schema modeling, window function analysis |
| **pgAdmin** | Database administration |
| **Power BI (DAX, Power Query)** | Dashboarding, connected live via Import mode to PostgreSQL |

---

<p align="center"><i>Built by Bhanu Prakash Jajapuram</i></p>
