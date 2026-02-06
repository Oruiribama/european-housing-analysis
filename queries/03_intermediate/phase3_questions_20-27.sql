/*
================================================================================
PHASE 3: INTERMEDIATE CHALLENGES (Questions 20-27)
================================================================================
Purpose: Multi-metric comparisons, statistical analysis, pattern recognition
Skills: CASE statements, STDEV, complex filtering, comparative analysis
================================================================================
*/

-- ============================================================================
-- Question 20: Portugal's Growth (2023-Q1 to 2025-Q3)
-- ============================================================================
-- Purpose: Calculate total growth over specific time period
-- Business Value: Long-term investment performance measurement

SELECT 
    MAX(CASE WHEN quarter = '2023-Q1' THEN price_index END) AS start_price,
    MAX(CASE WHEN quarter = '2025-Q3' THEN price_index END) AS end_price,
    CAST(
        (MAX(CASE WHEN quarter = '2025-Q3' THEN price_index END) - 
         MAX(CASE WHEN quarter = '2023-Q1' THEN price_index END)) 
        * 100.0 / 
        MAX(CASE WHEN quarter = '2023-Q1' THEN price_index END)
    AS DECIMAL(10, 2)) AS percentage_growth
FROM dbo.european_housing_prices_clean
WHERE country = 'Portugal'
  AND quarter IN ('2023-Q1', '2025-Q3');

/*
RESULT:
Start (2023-Q1): 198.55
End (2025-Q3): 269.35
Growth: 35.66% over 2.5 years

INSIGHT: Portugal = Strong performer with 35%+ growth in recent years
*/


-- ============================================================================
-- Question 21: Market Volatility Ranking
-- ============================================================================
-- Purpose: Identify most and least volatile markets
-- Business Value: Risk assessment for investment portfolios

-- Most volatile markets
SELECT TOP 5 
    country, 
    STDEV(quarterly_change_pct) AS volatility
FROM dbo.european_housing_prices_clean
WHERE country_type = 'Individual'
GROUP BY country
ORDER BY volatility DESC;

/*
RESULTS:
1. Türkiye: 6.24 (hyperinflation swings)
2. Hungary: 3.22
3. Cyprus: 3.14
4. Luxembourg: 2.82
5. Norway: 2.62

INSIGHT: Türkiye 19× more volatile than Malta!
*/

-- Most stable markets
SELECT TOP 5 
    country, 
    STDEV(quarterly_change_pct) AS stability
FROM dbo.european_housing_prices_clean
WHERE country_type = 'Individual'
GROUP BY country
ORDER BY stability ASC;

/*
RESULTS:
1. Malta: 0.33 (ultra-stable)
2. Lithuania: 0.65
3. Belgium: 0.88
4. Switzerland: 0.97
5. Italy: 1.19

INSIGHT: Low volatility = predictable, conservative investments
*/


-- ============================================================================
-- Question 22: Average Yearly Growth by Year
-- ============================================================================
-- Purpose: Track market trends over time
-- Business Value: Identify market cycles and recovery patterns

SELECT 
    year, 
    AVG(yearly_change_pct) AS avg_yearly_growth
FROM dbo.european_housing_prices_clean
WHERE country_type = 'Individual'
GROUP BY year
ORDER BY year;

/*
RESULTS:
2022: 13.08% (post-pandemic boom)
2023: 5.95% (correction - interest rate shock)
2024: 6.63% (recovery begins)
2025: 6.89% (sustained growth)

INSIGHT: Market stabilized at healthy 6-7% after 2023 correction
*/


-- ============================================================================
-- Question 23: EU vs Non-EU Performance (2024-2025)
-- ============================================================================
-- Purpose: Compare EU membership impact on housing markets
-- Business Value: Policy and economic structure analysis

SELECT 
    eu_member, 
    AVG(yearly_change_pct) AS avg_growth_rate
FROM dbo.european_housing_prices_clean
WHERE year BETWEEN 2024 AND 2025
  AND country_type = 'Individual'
GROUP BY eu_member
ORDER BY eu_member;

/*
RESULTS:
No: 11.09% (dominated by Türkiye hyperinflation)
Yes: 6.13%

BREAKDOWN:
- Türkiye (Non-EU): 43.70% (outlier - hyperinflation)
- Without Türkiye: Non-EU ~4.9%, EU 6.13%

INSIGHT: EU members actually perform better when outliers excluded
*/


-- ============================================================================
-- Question 24: Eurozone vs Non-Eurozone (2024-2025)
-- ============================================================================
-- Purpose: Analyze shared currency impact
-- Business Value: Monetary policy effectiveness study

SELECT 
    eurozone_member, 
    AVG(yearly_change_pct) AS avg_growth
FROM dbo.european_housing_prices_clean
WHERE year BETWEEN 2024 AND 2025
  AND country_type = 'Individual'
GROUP BY eurozone_member
ORDER BY eurozone_member;

/*
RESULTS:
No (Non-Eurozone): 9.52%
Yes (Eurozone): 5.19%

BREAKDOWN BY COUNTRY (Non-Eurozone):
- Türkiye: 43.70% (hyperinflation)
- Bulgaria: 15.99%
- Hungary: 15.93%
- Poland: 10.83%

INSIGHT: Eastern European countries with own currencies outperformed
Currency flexibility = advantage during crisis recovery
*/


-- ============================================================================
-- Question 25: Consistent Growers (Zero Negative Quarters)
-- ============================================================================
-- Purpose: Identify most reliable markets
-- Business Value: Low-risk investment opportunities

SELECT country
FROM dbo.european_housing_prices_clean
WHERE country_type = 'Individual'
GROUP BY country
HAVING MIN(quarterly_change_pct) >= 0;

/*
RESULTS: Only 6 countries!
1. Bulgaria
2. Croatia
3. Lithuania
4. Malta
5. Portugal
6. Türkiye

INSIGHT: Consistency is rare! Only 20% of markets never declined
*/


-- ============================================================================
-- Question 26: Hot Markets in 2025-Q3
-- ============================================================================
-- Purpose: Current opportunity identification
-- Business Value: Recent strong performers with momentum

SELECT DISTINCT country
FROM dbo.european_housing_prices_clean
WHERE yearly_change_pct > 5 
  AND quarterly_change_pct > 2
  AND country_type = 'Individual'
  AND quarter = '2025-Q3'
ORDER BY country;

/*
RESULTS: 12 hot markets
Bulgaria, Croatia, Czechia, Denmark, Hungary, Ireland, 
Latvia, Lithuania, Portugal, Romania, Slovakia, Spain

INSIGHT: 40% of European markets are "hot" in latest quarter
Eastern Europe dominates (8 of 12)
*/


-- ============================================================================
-- Question 27: Recovery Stories (Negative 2023 → Positive 2024)
-- ============================================================================
-- Purpose: Identify resilient markets
-- Business Value: Turnaround investment opportunities

SELECT 
    country,
    AVG(CASE WHEN year = 2023 THEN yearly_change_pct END) AS growth_2023,
    AVG(CASE WHEN year = 2024 THEN yearly_change_pct END) AS growth_2024
FROM dbo.european_housing_prices_clean
WHERE country_type = 'Individual'
GROUP BY country
HAVING 
    AVG(CASE WHEN year = 2023 THEN yearly_change_pct END) < 0
    AND 
    AVG(CASE WHEN year = 2024 THEN yearly_change_pct END) > 0
ORDER BY growth_2024 DESC;

/*
RESULTS: 5 recovery stories
1. Denmark: -0.50% → +5.20% (strongest recovery)
2. Sweden: -2.90% → +2.40%
3. Germany: -6.30% → +1.90%
4. Luxembourg: -1.70% → +1.40%
5. Austria: -0.20% → +1.10%

INSIGHT: All Western/Northern European - recovered from 2023 crisis
Eastern Europe never needed recovery (avoided crisis)
*/


-- ============================================================================
-- SUMMARY: Phase 3 Findings
-- ============================================================================
/*
KEY INSIGHTS:

1. VOLATILITY VS GROWTH
   - Bulgaria: High growth (13.73%) with low volatility (1.75)
   - Malta: Low growth (6.25%) with ultra-low volatility (0.33)
   - Trade-off exists but not absolute

2. MARKET CYCLES IDENTIFIED
   - 2022: Boom (13% avg)
   - 2023: Bust (6% avg)
   - 2024-2025: Recovery (7% avg)
   - Full cycle took ~3 years

3. CURRENCY MATTERS
   - Eurozone: One-size-fits-all policy hit hard in 2023
   - Non-Eurozone: Flexibility helped Eastern Europe thrive
   - Gap narrowing in 2024-2025 as markets converge

4. CONSISTENCY IS RARE
   - Only 6 countries never declined
   - 4 are EU members (Bulgaria, Croatia, Lithuania, Portugal)
   - Reliability = valuable asset

5. WESTERN EUROPE RESILIENCE
   - Hit hardest in 2023 (Denmark -3.80%, Germany -6.30%)
   - Strong recovery by 2024 (Denmark +5.20%)
   - Mature markets = volatile but bounce back

NEXT PHASE: Advanced Analysis (Custom metrics, pattern detection) →
*/
```



