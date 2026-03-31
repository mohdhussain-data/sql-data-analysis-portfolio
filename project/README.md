# Sales Performance Analysis (SQL Project)

## 📌 Overview
This project analyzes B2B sales data from the Parch & Posey dataset to evaluate revenue performance, customer behavior, and business growth trends.

The analysis focuses on identifying key revenue drivers and generating actionable business insights using SQL.

---

## 🎯 Objectives
- Identify top revenue-generating customers
- Analyze regional sales performance
- Evaluate sales representative contribution
- Track revenue trends over time (YoY & Monthly)
- Segment customers based on revenue
- Distinguish repeat vs one-time customers
- Measure marketing channel effectiveness

---

## 🗂️ Dataset
- Parch & Posey dataset (B2B sales company simulation)
- Tables used:
  - accounts
  - orders
  - sales_reps
  - region
  - web_events

---

## 🧠 Key Analysis Performed

### 1. Customer Revenue Contribution
- Identified top customers
- Calculated revenue share %

### 2. Regional Performance
- Compared revenue across regions
- Identified strongest and weakest markets

### 3. Sales Rep Performance
- Ranked sales representatives
- Evaluated contribution to total revenue

### 4. Revenue Trends
- Year-over-Year growth
- Monthly revenue patterns
- Identified growth periods and anomalies

### 5. Customer Segmentation
- Segmented customers using NTILE(4)
- Classified into:
  - High Value
  - Mid-High
  - Mid-Low
  - Low Value

### 6. Customer Behavior
- Repeat vs one-time customers
- Identified strong retention patterns

### 7. Marketing Channel Analysis
- Evaluated engagement by channel
- Identified dominant acquisition sources

---

## 📊 Key Insights
- Revenue is diversified across customers (low concentration)
- Northeast & Southeast dominate regional performance
- Strong YoY growth observed (2014–2016)
- High-value customers contribute majority revenue (~64%)
- 95% customers are repeat buyers
- Direct channel dominates engagement (~58%)

---

## 🛠️ Skills Demonstrated
- Complex Joins
- Aggregations & Grouping
- Window Functions (RANK, LAG, NTILE)
- CTEs
- Subqueries
- Business-oriented SQL analysis

---

## ⚠️ Limitations
- Dataset is simulated
- Some time periods contain incomplete data

---

## 🚀 Conclusion
This project demonstrates the ability to translate business questions into structured SQL queries and extract actionable insights from relational data.

It reflects real-world data analyst responsibilities including data exploration, performance analysis, and business decision support.