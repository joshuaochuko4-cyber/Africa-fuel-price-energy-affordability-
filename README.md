# Africa-fuel-price-energy-affordability-
# ⛽ Africa Fuel Price & Energy Affordability Analysis

### Built with SQL Server & Power BI | By Isah Joshua

![full video walkthrough](https://drive.google.com/file/d/1jx4wg3FuhvOVdOQpwkXk2829DQt6_9km/view?usp=drivesdk)

---

## 📌 Project Overview
Designed and developed a complete end-to-end data analytics project
analysing fuel prices and energy affordability across 6 African
countries — Nigeria, Ghana, Kenya, South Africa, Egypt and Ethiopia
— from 2020 to 2023. The project covers the full data pipeline from
raw data cleaning in SQL Server through to a 4-page interactive
Power BI dashboard with 27 DAX measures.

---

## ❓ Problem Statement
Fuel prices across Africa vary significantly and have a direct impact
on the daily lives of citizens. Governments use subsidies to shield
consumers from global oil price volatility but with mixed results.
This project investigates price trends, subsidy impact, black market
premiums and energy affordability relative to minimum wages across
6 countries over 4 years.

---

## 🎯 Objective
To clean, transform and analyse 119,922 rows of real-world messy
fuel price data and deliver actionable insights around price trends,
energy affordability, black market activity and data quality — all
through an interactive 4-page Power BI dashboard.

---

## 🛠️ Tools Used
- Microsoft SQL Server (SSMS)
- Power BI Desktop
- DAX (Data Analysis Expressions)
- Power Query
- Data Visualization Best Practices

---

## 🔧 Data Preparation & Cleaning
- Imported 119,922 rows of raw messy data into SQL Server staging table
- Applied a 15-step SQL Server cleaning pipeline covering all major issues
- Standardised 30+ country name variants to 6 standard names using CASE
- Parsed 9 different date formats to YYYY-MM-DD using TRY_CONVERT
- Stripped all currency symbols from the price column using chained REPLACE
- Standardised currency codes to ISO 4217 format (NGN, GHS, KES, ZAR, EGP, ETB)
- Removed ~6,000 silent duplicate records using CTE ROW_NUMBER deduplication
- Flagged and removed negative prices, extreme outliers and invalid countries
- Created final clean table using SELECT INTO with proper typed columns
- Achieved 68,350 clean records — a 57% data retention rate

---

## 📐 Data Modeling & Measures
- Connected Power BI directly to SQL Server — no CSV export needed
- Created a DateTable using DAX CALENDAR function for time intelligence
- Established One to Many relationship between DateTable and FuelData
- Built 27 DAX measures across 6 groups:
  - Core KPIs — Total Records, Avg Price Local, Total Countries, Pct Subsidised
  - Time Intelligence — Price MoM Change, Price YoY Change, Rolling 3M Avg, YTD Avg
  - Affordability — Affordability Index, Litres Per Day Wage, Black Market Premium
  - Data Quality — Raw Record Count, Clean Record Count, Data Retention Rate
  - Dynamic Labels — Dynamic Chart Title, Selected Country, Selected Fuel Type
  - Comparison — Subsidised Avg Price, Market Avg Price, Price vs Country Avg

---

## 📈 Dashboard Features
- **KPI Cards** — Total Records (68,350), Countries (6), Subsidy Coverage (57%), Avg Price
- **Price by Country Bar Chart** — average fuel price per litre in local currency
- **Shape Map** — geographic fuel price distribution across Africa
- **Official Pump vs Black Market Donut** — price channel split across all records
- **Monthly Price Trend Line Chart** — all 6 countries from 2020 to 2023
- **Subsidised vs Market Price Chart** — impact of government subsidies per country
- **YoY Price Change Column Chart** — conditional green and red colouring
- **Affordability Index Hero Bar** — % of daily minimum wage per country
- **Litres Per Day Wage Chart** — how many litres a worker can afford daily
- **Black Market Premium Chart** — % above official pump price per country
- **Affordability Heatmap Matrix** — country vs year with Red-Amber-Green formatting
- **Data Quality Report Page** — issues by type, pipeline summary, coverage timeline
- **Interactive Slicers** — filter by Country, Fuel Type and Year across all pages

---

## 💡 Key Insights
- A Nigerian minimum wage worker spends **73%** of their daily income on
  just 1 litre of fuel — the most critical affordability gap in the dataset
- Egypt is the most affordable at just **10%** — workers can buy 8+ litres
  per day's wage due to active government subsidies
- Nigeria's subsidy removal in **June 2023** caused a **22% single-month
  price spike** — the biggest price event in the entire 4-year dataset
- Nigeria's black market fuel costs **38% above** the official pump price
  — hitting the most vulnerable consumers hardest
- **Every single country** became less affordable in 2023 — this is a
  continent-wide crisis, not just a Nigeria problem
- Kenya recorded rising prices **every single quarter** from 2020 to 2023
  — the most consistent upward trend in the dataset

---

## 💼 Business Impact
The dashboard enables energy analysts, NGOs, government agencies and
business stakeholders to monitor fuel price trends, understand the
impact of subsidy policies, identify affordability crises at a country
level, and track data quality metrics — all through interactive
filtering for deeper, faster analysis.

---


## 📁 Files in This Repository
| File | Description |
|------|-------------|
| `<img width="897" height="546" alt="image" src="https://github.com/user-attachments/assets/3f8bc4a3-5c36-4242-bd95-8f3583e3ec19" />, <img width="899" height="544" alt="image" src="https://github.com/user-attachments/assets/3b60f87e-c685-44fb-87fe-b34c6217aec5" />,<img width="914" height="543" alt="image" src="https://github.com/user-attachments/assets/828110b2-80cf-4f73-b71b-e8df783c8ec9" />, <img width="895" height="540" alt="image" src="https://github.com/user-attachments/assets/afe1b487-a874-434c-985b-3d2ebe3227e4" />



` | Screenshot of the Power BI Dasboards
Complete 15-step SQL Server cleaning script |

---

## 🔗 Connect With Me
[LinkedIn](https://www.linkedin.com/in/isah-joshua)
