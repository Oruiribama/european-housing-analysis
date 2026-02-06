/*
================================================================================
PHASE 4: ADVANCED BUSINESS QUESTIONS (Questions 28-33)
================================================================================
Purpose: Expert-level analysis with custom metrics and complex logic
Skills: Window functions (LAG), CTEs, custom scoring, pattern detection
================================================================================
*/

-- ============================================================================
-- Question 28: Housing Health Score
-- ============================================================================
-- Purpose: Create proprietary investment scoring system
-- Business Value: Combine growth and stability into single ranking metric

SELECT 
    country,
    CAST(AVG(yearly_change_pct) AS DECIMAL(10,2)) AS avg_yearly_growth,
    CAST(STDEV(quarterly_change_pct) AS DECIMAL(10,2)) AS volatility,
    CAST(
        (AVG(yearly_change_pct) * 2) - STDEV(quarterly_change_pct) 
    AS DECIMAL(10,2)) AS health_score
FROM dbo.european_housing_prices_clean
WHERE year BETWEEN 2024 AND 2025
  AND country_type = 'Individual'
GROUP BY country
ORDER BY health_score DESC;

/*
FORMULA: Health Score = (Avg Growth × 2) - Volatility
- Growth weighted 2× because long-term returns matter more
- Volatility subtracted as risk penalty

TOP RESULTS:
1. Bulgaria: 25.71 (high growth + low volatility)
2. Croatia: 22.68
3. Hungary: 21.42 (but watch for overheating)
4. Lithuania: 19.83
5. Portugal: 18.86

BOTTOM:
Germany, Austria, France (crisis recovery still weak)

INSIGHT: Eastern Europe dominates health rankings
*/


-- ============================================================================
-- Question 29: Overheating Markets Detection
-- ============================================================================
-- Purpose: Identify bubble-risk markets
-- Business Value: Warning system for unsustainable growth

SELECT 
    country, 
    year, 
    quarter, 
    yearly_change_pct, 
    quarterly_change_pct
FROM dbo.european_housing_prices_clean
WHERE yearly_change_pct > 15 
  AND quarterly_change_pct > 5
  AND country_type = 'Individual' 
ORDER BY yearly_change_pct DESC;

/*
THRESHOLD: 15%+ yearly AND 5%+ quarterly = Overheating

RESULTS:
- Türkiye: 9 quarters (2022-2024) - hyperinflation crisis
- Hungary: 1 quarter (2025-Q1 at 17%) - approaching danger zone
- Bulgaria: 1 quarter (brief spike, recovered)

HISTORICAL CONTEXT:
- USA 2005-2007: 15-20% → 2008 crash
- Spain 2000-2007: 12-15% → -40% decline
- Japan 1980s: 20%+ → Lost decades

CURRENT STATUS: Most markets NOT overheating (healthy)
*/


-- ============================================================================
-- Question 30: Best EU Investment (Consistent + High Growth)
-- ============================================================================
-- Purpose: Find ideal investment combining safety and returns
-- Business Value: Low-risk, high-reward opportunities

SELECT 
    country, 
    AVG(yearly_change_pct) AS avg_yearly_growth
FROM dbo.european_housing_prices_clean
WHERE eu_member = 'Yes'
  AND country_type = 'Individual'
GROUP BY country
HAVING MIN(quarterly_change_pct) >= 0  -- Zero negative quarters
ORDER BY avg_yearly_growth DESC;

/*
CRITERIA:
✓ EU member (stability)
✓ Never had negative quarter (consistency)
✓ Ranked by growth (returns)

RESULTS:
1. Bulgaria: 13.73% (WINNER - Triple Crown!)
2. Croatia: 12.25%
3. Portugal: 10.96%
4. Lithuania: 10.24%
5. Malta: 6.25%

INSIGHT: Bulgaria = Best risk-adjusted EU investment
- High growth + perfect consistency + EU membership
*/


-- ============================================================================
-- Question 31: Momentum Analysis (Accelerating Growth)
-- ============================================================================
-- Purpose: Identify markets with building momentum
-- Business Value: Early detection of emerging opportunities

SELECT 
    country,
    AVG(CASE WHEN year = 2023 THEN yearly_change_pct END) AS avg_2023,
    AVG(CASE WHEN year = 2024 THEN yearly_change_pct END) AS avg_2024,
    AVG(CASE WHEN year = 2025 THEN yearly_change_pct END) AS avg_2025
FROM dbo.european_housing_prices_clean
WHERE country_type = 'Individual'
  AND year IN (2023, 2024, 2025)
GROUP BY country
HAVING 
    AVG(CASE WHEN year = 2023 THEN yearly_change_pct END) < 
    AVG(CASE WHEN year = 2024 THEN yearly_change_pct END)
    AND
    AVG(CASE WHEN year = 2024 THEN yearly_change_pct END) < 
    AVG(CASE WHEN year = 2025 THEN yearly_change_pct END)
ORDER BY avg_2025 DESC;

/*
CRITERIA: 2023 < 2024 < 2025 (continuous acceleration)

SUPER ACCELERATORS:
1. Hungary: 7.18% → 13.68% → 18.93% (explosive!)
2. Portugal: 8.20% → 9.05% → 17.07% (2025 surge)
3. Spain: 4.00% → 8.50% → 12.63%

RECOVERY ACCELERATORS:
- Slovakia: -0.05% → 3.78% → 12.30% (amazing turnaround)
- Czechia: -1.63% → 4.98% → 10.40%
- Denmark: -3.80% → 3.50% → 7.67%

INSIGHT: 16 countries showing acceleration
Momentum typically continues - these are near-term opportunities
*/


-- ============================================================================
-- Question 32: Crisis Detection (3+ Consecutive Declines)
-- ============================================================================
-- Purpose: Identify sustained market crises
-- Business Value: Risk management and early warning system

-- Step 1: Get each quarter plus previous 2 quarters using LAG
WITH quarter_history AS (
    SELECT 
        country,
        quarter,
        quarterly_change_pct AS current_qtr,
        LAG(quarterly_change_pct, 1) OVER (PARTITION BY country ORDER BY year, quarter_num) AS prev_qtr_1,
        LAG(quarterly_change_pct, 2) OVER (PARTITION BY country ORDER BY year, quarter_num) AS prev_qtr_2
    FROM dbo.european_housing_prices_clean
    WHERE country_type = 'Individual'
)

-- Step 2: Find countries where all 3 consecutive quarters were negative
SELECT DISTINCT country
FROM quarter_history
WHERE current_qtr < 0 
  AND prev_qtr_1 < 0 
  AND prev_qtr_2 < 0
ORDER BY country;

/*
ADVANCED TECHNIQUE: Window functions with LAG
- LAG(column, 1) = previous quarter
- LAG(column, 2) = 2 quarters back
- PARTITION BY country = separate analysis per country

RESULTS: 9 countries in crisis
Austria, Belgium, Estonia, Finland, France,
Latvia, Luxembourg, Norway, Sweden

STILL STRUGGLING (2024-Q4):
- Finland: -1.80%
- France: -1.90%

FULLY RECOVERED:
- Denmark, Slovakia (not in list - recovered before 3 consecutive)

INSIGHT: Sustained declines = serious crisis signal
Western/Northern Europe hit hardest
*/


-- ============================================================================
-- Question 33: Market Correlation (Eurozone Synchronization)
-- ============================================================================
-- Purpose: Test if shared currency creates synchronized markets
-- Business Value: Understanding policy impacts and diversification

SELECT
    year,
    quarter,
    -- 1. Eurozone Average
    CAST(AVG(CASE WHEN eurozone_member = 'Yes' THEN quarterly_change_pct END) 
        AS DECIMAL(10,2)) AS eurozone_avg,
    
    -- 2. Non-Eurozone Average
    CAST(AVG(CASE WHEN eurozone_member = 'No' THEN quarterly_change_pct END) 
        AS DECIMAL(10,2)) AS non_eurozone_avg,
    
    -- 3. The Gap (Divergence metric)
    CAST(
        AVG(CASE WHEN eurozone_member = 'No' THEN quarterly_change_pct END) -
        AVG(CASE WHEN eurozone_member = 'Yes' THEN quarterly_change_pct END)
    AS DECIMAL(10,2)) AS divergence_gap
FROM dbo.european_housing_prices_clean
WHERE country_type = 'Individual'
GROUP BY year, quarter
ORDER BY year, quarter;

/*
TIMELINE OF CONVERGENCE:

2023-Q3: Gap = 2.39 (WIDEST divergence)
- Eurozone: 0.25%
- Non-Eurozone: 2.64%
- ECB policy hurt Eurozone more

2024-Q3: Gap = 0.38 (NARROWEST)
- Markets converging
- Adaptation to high rates

2025-Q2: Gap = -0.21 (REVERSAL!)
- Eurozone: 2.15% > Non-Eurozone: 1.94%
- FIRST TIME Eurozone outperformed!

INSIGHT: Markets DO synchronize (eventually)
- Shared currency creates lag but eventual convergence
- 2-year cycle from divergence to convergence
- Non-Eurozone advantage during crisis (flexibility)
- Eurozone advantage during recovery (stability)
*/


-- ============================================================================
-- SUMMARY: Phase 4 Findings
-- ============================================================================
/*
EXPERT-LEVEL INSIGHTS:

1. HEALTH SCORE RANKINGS
   - Bulgaria: Best overall (high growth + low risk)
   - Eastern Europe: 4 of top 5 positions
   - Custom metrics reveal hidden gems

2. OVERHEATING RARE
   - Only 3 countries touched danger zone
   - Türkiye = crisis, not opportunity
   - Most markets at healthy 6-12% growth

3. PERFECT INVESTMENT: BULGARIA
   - EU member ✓
   - Zero negative quarters ✓
   - 13.73% average growth ✓
   - Meets all criteria

4. MOMENTUM MATTERS
   - 16 accelerating markets
   - Hungary, Portugal, Spain leading
   - Acceleration often continues (trend following)

5. CRISIS DETECTION WORKS
   - 9 countries had sustained declines
   - Pattern: 3+ consecutive quarters = serious
   - Finland, France still struggling

6. EUROZONE CONVERGENCE CONFIRMED
   - 2023: Massive divergence (2.39 gap)
   - 2025: Convergence complete (-0.21 reversal)
   - Shared currency = synchronized cycles (with lag)

FINAL CONCLUSION:
Eastern Europe = Best opportunity (growth + stability)
Western Europe = Recovery plays (resilience but slower)
Türkiye = Avoid (hyperinflation, not growth)
Portugal = Only market in all "best" categories

INVESTMENT STRATEGY:
- Aggressive: Bulgaria, Hungary (high growth)
- Balanced: Portugal, Croatia (proven + momentum)
- Conservative: Malta, Lithuania (ultra-stable)
- Avoid: Finland, France (crisis continues)

PROJECT COMPLETE! 🎉
*/
```



