/*
================================================================================
PHASE 2: BASIC BUSINESS ANALYSIS (Questions 11-19)
================================================================================
Purpose: Rankings, comparisons, and basic aggregations for business insights
Skills: TOP/LIMIT, ORDER BY, AVG(), filtering, GROUP BY
================================================================================
*/

-- ============================================================================
-- Question 11: Top 5 Highest Price Index (2025-Q3)
-- ============================================================================
-- Purpose: Identify most expensive markets
-- Business Value: Shows which countries have had highest cumulative growth since 2015

SELECT TOP 5
    country,
    price_index
FROM dbo.european_housing_prices_clean
WHERE quarter = '2025-Q3'
  AND country_type = 'Individual'
ORDER BY price_index DESC;

/*
RESULTS:
1. Hungary: 375.19 (3.75× growth since 2015)
2. Portugal: 269.35
3. Poland: 265.13
4. Lithuania: 262.01
5. Bulgaria: 256.01

INSIGHT: Eastern European countries dominate - massive growth in emerging markets
*/


-- ============================================================================
-- Question 12: Top 5 Biggest Price Crashes (Most Negative Yearly Change)
-- ============================================================================
-- Purpose: Identify worst performing quarters
-- Business Value: Risk assessment - which markets crashed hardest

SELECT TOP 5
    country,
    quarter,
    yearly_change_pct
FROM dbo.european_housing_prices_clean
WHERE country_type = 'Individual'
ORDER BY yearly_change_pct ASC;  -- ASC for most negative

/*
RESULTS:
1. Luxembourg 2023-Q3: -14.50%
2. Luxembourg 2023-Q4: -13.90%
3. Luxembourg 2023-Q2: -11.20%
4. Germany 2023-Q4: -10.20%
5. Germany 2023-Q3: -9.40%

INSIGHT: 2023 was crisis year for Western Europe (interest rate shock)
*/


-- ============================================================================
-- Question 13: Top 3 Cumulative Growth Since 2015
-- ============================================================================
-- Purpose: Identify best long-term performers
-- Business Value: Historical investment winners

-- Most recent quarter (2025-Q3) - excludes Türkiye due to data coverage
SELECT TOP 3
    country,
    price_change_since_2015_pct
FROM dbo.european_housing_prices_clean
WHERE quarter = '2025-Q3'
  AND country_type = 'Individual'
  AND country != 'Türkiye'  -- Only has data through 2024-Q4
ORDER BY price_change_since_2015_pct DESC;

/*
RESULTS:
1. Hungary: 275.19%
2. Portugal: 169.35%
3. Iceland: 165.13%

INSIGHT: Hungary tripled prices since 2015; Türkiye excluded (hyperinflation outlier)
*/


-- ============================================================================
-- Question 14: Austria's Negative Quarterly Growth Periods
-- ============================================================================
-- Purpose: Identify market decline periods for specific country
-- Business Value: Understanding market cycles

SELECT 
    quarter,
    quarterly_change_pct
FROM dbo.european_housing_prices_clean
WHERE country = 'Austria'
  AND quarterly_change_pct < 0
ORDER BY year, quarter_num;

/*
RESULTS: 6 negative quarters
2022-Q4: -0.80%
2023-Q1: -1.20%
2023-Q3: -0.20%
2023-Q4: -1.80%
2024-Q1: -1.20%
2024-Q4: -0.60%

INSIGHT: Austria struggled throughout 2022-2024 with intermittent declines
*/


-- ============================================================================
-- Question 15: EU Members NOT in Eurozone
-- ============================================================================
-- Purpose: Identify countries with EU membership but own currency
-- Business Value: Currency flexibility analysis

SELECT DISTINCT country
FROM dbo.european_housing_prices_clean
WHERE eu_member = 'Yes'
  AND eurozone_member = 'No'
ORDER BY country;

/*
RESULTS: ~7 countries
Bulgaria, Czechia, Denmark, Hungary, Poland, Romania, Sweden

INSIGHT: These countries have EU benefits + monetary policy independence
*/


-- ============================================================================
-- Question 16: Records with >10% Yearly Growth (Hot Markets)
-- ============================================================================
-- Purpose: Identify all instances of strong growth
-- Business Value: Find consistent hot markets

SELECT 
    country,
    quarter,
    yearly_change_pct
FROM dbo.european_housing_prices_clean
WHERE yearly_change_pct > 10
  AND country_type = 'Individual'
ORDER BY yearly_change_pct DESC;

/*
TOP RESULTS:
Türkiye 2022-Q4: 170.50% (hyperinflation)
Türkiye 2023-Q1: 142.70%
Hungary 2025-Q3: 21.10%
Iceland 2022-Q4: 21.00%
Bulgaria 2024-Q4: 18.30%

INSIGHT: Türkiye dominates but is outlier; Eastern Europe shows genuine hot markets
*/


-- ============================================================================
-- Question 17: Average Price Index (2025-Q3)
-- ============================================================================
-- Purpose: Calculate baseline "typical" market level
-- Business Value: Benchmark for comparing individual countries

SELECT AVG(price_index) AS avg_price_index
FROM dbo.european_housing_prices_clean
WHERE quarter = '2025-Q3'
  AND country_type = 'Individual';

/*
RESULT: 196.45

INSIGHT: Average European country is ~2× 2015 prices (96% increase)
*/


-- ============================================================================
-- Question 18: Highest and Lowest Quarterly Changes Ever
-- ============================================================================
-- Purpose: Find extreme volatility bounds
-- Business Value: Understanding market volatility range

SELECT 
    MIN(quarterly_change_pct) AS lowest_quarterly_change,
    MAX(quarterly_change_pct) AS highest_quarterly_change
FROM dbo.european_housing_prices_clean
WHERE country_type = 'Individual';

/*
RESULTS:
Lowest: -6.60%
Highest: 22.70%

INSIGHT: 29.3 point spread shows significant quarterly volatility possible
*/


-- ============================================================================
-- Question 19: Countries with Positive Yearly Growth (2024-Q4)
-- ============================================================================
-- Purpose: Count markets in growth vs decline at year-end
-- Business Value: Market health assessment

SELECT COUNT(DISTINCT country) AS countries_with_positive_growth
FROM dbo.european_housing_prices_clean
WHERE yearly_change_pct > 0
  AND quarter = '2024-Q4'
  AND country_type = 'Individual';

/*
RESULT: 28 countries with positive growth

VERIFICATION: Only 2 negative (Finland -1.80%, France -1.90%)

INSIGHT: 93% of markets growing by end of 2024 - strong recovery from 2023 crisis
*/


-- Verification query: Who was negative?
SELECT 
    country,
    yearly_change_pct
FROM dbo.european_housing_prices_clean
WHERE quarter = '2024-Q4'
  AND country_type = 'Individual'
  AND yearly_change_pct <= 0
ORDER BY yearly_change_pct;


-- ============================================================================
-- SUMMARY: Phase 2 Findings
-- ============================================================================
/*
KEY INSIGHTS:

1. EASTERN EUROPEAN DOMINANCE
   - Hungary, Poland, Bulgaria in top 5 price index
   - 10-20% growth rates vs Western Europe's 2-5%

2. 2023 CRISIS CONFIRMED
   - Luxembourg: -14.50% worst crash
   - Germany: -10.20% decline
   - Western Europe hit hardest

3. RECOVERY BY 2024-Q4
   - 28/30 countries positive
   - Only Finland, France still struggling

4. VOLATILITY RANGE
   - Quarterly swings: -6.60% to +22.70%
   - Annual average: ~6-7% (healthy level)

5. EU FLEXIBILITY
   - 7 countries have EU benefits + own currency
   - Notable: Poland, Hungary, Czechia (strong performers)

NEXT PHASE: Intermediate Analysis (Multi-metric comparisons) →
*/
