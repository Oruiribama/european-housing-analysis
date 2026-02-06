# European Housing Market SQL Analysis

**A comprehensive SQL analysis of European housing prices (2022-2025)**
---

## 📊 Project Overview

This project demonstrates advanced SQL skills through a real-world analysis of European housing market data. Over 33 progressive queries, I explore patterns, detect crises, identify investment opportunities, and uncover economic insights across 30+ European countries.

**Key Achievement:** Progressed from basic data exploration to expert-level analysis using window functions, CTEs, and complex business logic.

---

## 🎯 Key Findings

### 🏆 Best Investment Markets
- **Bulgaria**: 13.73% average growth with perfect consistency (zero negative quarters)
- **Portugal**: Only market with both consistency AND acceleration (17.07% in 2025)
- **Eastern Europe**: Dominates top performers with 8 of 12 "hot markets"

### 🚨 Crisis Detection
- **9 countries** experienced sustained declines (3+ consecutive quarters)
- **Luxembourg**: Worst crash at -14.50% yearly decline
- **Recovery success**: Germany, Austria, Denmark bounced back by 2024-2025

### 📈 Market Dynamics
- **Türkiye**: Extreme hyperinflation (170% growth) - currency crisis, not prosperity
- **Eurozone convergence**: Markets synchronized after 2-year divergence period
- **Eastern European momentum**: Consistent 10-15% growth as economies catch up to West

---

## 🛠️ Technical Skills Demonstrated

### SQL Expertise
- **Aggregations**: COUNT, AVG, MIN, MAX, SUM, STDEV
- **Window Functions**: LAG, LEAD with PARTITION BY
- **Advanced Techniques**: CTEs, subqueries, pivoting with CASE statements
- **Complex Logic**: Multi-condition filtering, consecutive pattern detection
- **Performance**: Optimized queries for large datasets

### Business Analysis
- Investment scoring models with weighted metrics
- Volatility and risk assessment
- Time-series trend analysis
- Outlier detection and handling
- Market correlation studies
- Crisis pattern recognition

---

## 📁 Repository Structure
```
├── sql-queries/
│   ├── phase-1-data-cleaning/       # Data validation & exploration
│   ├── phase-2-basic-analysis/      # Rankings, filters, aggregations
│   ├── phase-3-intermediate/        # Multi-metric comparisons
│   └── phase-4-advanced/            # Custom scoring, pattern detection
├── findings/
│   ├── key-insights.md              # Business insights summary
├── data/
│   └── european_housing_prices_clean.csv

```

---

## 📈 Sample Analyses

### 1. Housing Health Score (Custom Metric)
Created a proprietary scoring system combining growth and stability:
```sql
Health Score = (Avg Yearly Growth × 2) - Quarterly Volatility
```
**Result**: Bulgaria ranked #1 with score of 25.71

### 2. Crisis Detection (Advanced Window Functions)
Identified markets with 3+ consecutive quarterly declines using LAG():
```sql
WITH quarter_history AS (
    SELECT 
        country,
        quarterly_change_pct AS current_qtr,
        LAG(quarterly_change_pct, 1) OVER (PARTITION BY country ORDER BY quarter_num) AS prev_qtr_1,
        LAG(quarterly_change_pct, 2) OVER (PARTITION BY country ORDER BY quarter_num) AS prev_qtr_2
    ...
)
```
**Result**: 9 countries flagged, including Finland and France still struggling in 2024-Q4

### 3. Market Correlation Analysis
Compared Eurozone vs Non-Eurozone quarterly performance:
- **2023**: 2.39 point gap (Non-Eurozone outperformed)
- **2025-Q2**: -0.21 gap (Eurozone overtook for first time)
- **Insight**: Markets converging after 2-year divergence

---

## 🎓 Learning Journey

### Phase 1: Data Cleaning (Q1-10)
- Record counting, distinct values
- NULL handling and data quality checks
- Character encoding fixes (Türkiye)

### Phase 2: Basic Analysis (Q11-19)
- Top/bottom rankings
- Filtering with multiple conditions
- Basic aggregations (AVG, COUNT)

### Phase 3: Intermediate (Q20-27)
- Time-period comparisons
- Volatility analysis (STDEV)
- EU vs Non-EU performance
- Recovery story identification

### Phase 4: Advanced (Q28-33)
- Custom scoring algorithms
- Overheating detection (>15% growth)
- Momentum acceleration tracking
- Consecutive pattern detection with LAG
- Market synchronization analysis

---

## 💡 Key Insights by Topic

### Investment Strategy
✅ **Best overall**: Bulgaria (high growth + consistency + affordability)  
✅ **Western European star**: Portugal (proven track record + accelerating)  
✅ **Conservative pick**: Malta (ultra-stable with 0.33 volatility)  
❌ **Avoid**: Finland, France (still negative growth in 2024-Q4)

### Economic Patterns
- **Eastern Europe**: Catch-up phase with 10-15% sustainable growth
- **Western Europe**: Mature markets recovering from 2023 interest rate shock
- **Türkiye**: Outlier due to hyperinflation (43% growth = currency collapse)

### Market Timing
- **2023**: Correction year (avg 5.95% growth, many negative quarters)
- **2024**: Recovery begins (avg 6.63% growth)
- **2025**: Sustained growth + Eurozone overtakes Non-Eurozone

---

## 📊 Data Source

**Dataset**: European Housing Price Index (2022-2025)
- **Countries**: 28 individual + 7 aggregate regions
- **Records**: 417 quarterly observations
- **Metrics**: Price index, quarterly changes, yearly changes, cumulative growth
- **Coverage**: Q4 2022 through Q3 2025

---

## 🚀 How to Use This Repository

### For Recruiters
- Review `key-insights.md` for business analysis capabilities
- Check `sql-queries/phase-4-advanced/` for technical SQL expertise
- See `investment-recommendations.md` for strategic thinking

### For Fellow Analysts
- Use queries as templates for time-series analysis
- Adapt the Health Score formula for your datasets
- Learn LAG() patterns for consecutive detection

### To Run Queries
1. Import `european_housing_prices_clean.csv` into your SQL database
2. Execute queries in order from Phase 1 → Phase 4
3. Adjust table names if needed: `dbo.european_housing_prices_clean`

---

## 🎯 Skills Showcased

**Technical**
- Advanced SQL (CTEs, window functions, complex joins)
- Statistical analysis (volatility, correlation)
- Data quality validation
- Query optimization

**Business**
- Investment analysis and scoring
- Risk assessment
- Market trend identification
- Economic insight generation
- Data storytelling

**Analytical**
- Critical thinking (questioning hyperinflation data)
- Pattern recognition (Eastern European dominance)
- Outlier handling (Türkiye analysis)
- Cross-referencing findings across analyses

---

## 📝 About This Project

**Context**: Self-directed SQL mastery program  
**Duration**: Comprehensive multi-phase learning journey  
**Difficulty**: Beginner → Expert progression  
**Outcome**: 33 queries solving real-world business problems

This project demonstrates the ability to:
- Transform raw data into actionable insights
- Apply advanced SQL techniques to business problems
- Communicate findings to both technical and non-technical audiences
- Make data-driven investment recommendations

---

## 🤝 Connect

**Oruiribama**
- GitHub: [@Oruiribama](https://github.com/Oruiribama)
- LinkedIn: (https://www.linkedin.com/in/oruiribama-sampson-2014b8273?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=ios_app)]


---

## 📜 License

This project is available for educational and portfolio purposes.

---

**⭐ If you found this analysis insightful, please consider starring this repository!**
