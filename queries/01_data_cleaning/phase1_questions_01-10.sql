/*
================================================================================
PHASE 1: DATA CLEANING & EXPLORATION (Questions 1-10)
================================================================================
Purpose: Validate data quality, explore dataset structure, and identify issues
Skills: Basic SELECT, COUNT, DISTINCT, NULL handling, data validation
================================================================================
*/

-- ============================================================================
-- Question 1: Total Records
-- ============================================================================
-- Purpose: Verify data import success
-- Expected: ~417-418 records

SELECT COUNT(*) AS total_records
FROM dbo.european_housing_prices_clean;


-- ============================================================================
-- Question 2: Unique Countries
-- ============================================================================
-- Purpose: Understand dataset scope
-- Expected: ~35 unique values (including aggregates like "EU", "Euro area")

SELECT COUNT(DISTINCT country) AS unique_countries
FROM dbo.european_housing_prices_clean;


-- ============================================================================
-- Question 4: Duplicate Detection
-- ============================================================================
-- Purpose: Ensure data integrity (one record per country per quarter)
-- Expected: 0 duplicates

SELECT 
    country,
    quarter,
    COUNT(*) AS record_count
FROM dbo.european_housing_prices_clean
GROUP BY country, quarter
HAVING COUNT(*) > 1;
-- Result: 0 rows = No duplicates ✓


-- ============================================================================
-- Question 5-7: NULL Value Investigation
-- ============================================================================
-- Purpose: Identify missing data patterns

-- 5. Countries with NULL price_index
SELECT DISTINCT country
FROM dbo.european_housing_prices_clean
WHERE price_index IS NULL;
-- Result: Switzerland (12 records with NULL)

-- 6. Count NULL records
SELECT COUNT(*) AS null_price_index_count
FROM dbo.european_housing_prices_clean
WHERE price_index IS NULL;
-- Result: 12 rows

-- 7. Investigate Switzerland's data completeness
SELECT *
FROM dbo.european_housing_prices_clean
WHERE country = 'Switzerland'
ORDER BY year, quarter_num;
-- Finding: Switzerland has quarterly/yearly change percentages but NULL price_index
-- This is acceptable - different data availability


-- ============================================================================
-- Question 8: Negative Changes Detection
-- ============================================================================
-- Purpose: Identify market declines (normal economic behavior)

SELECT 
    country,
    quarter,
    quarterly_change_pct
FROM dbo.european_housing_prices_clean
WHERE quarterly_change_pct < 0
  AND country_type = 'Individual'
ORDER BY quarterly_change_pct;
-- Finding: Multiple countries with negative quarters (market declines are normal)


-- ============================================================================
-- DATA QUALITY VALIDATION: Quarterly Changes
-- ============================================================================
-- Purpose: Verify quarterly_change_pct calculations are accurate
-- Method: Self-join to compare reported vs calculated values

WITH quarterly_comparison AS (
    SELECT 
        curr.country,
        curr.quarter,
        curr.price_index AS current_price,
        prev.price_index AS previous_quarter_price,
        curr.quarterly_change_pct AS reported_quarterly_change,
        ROUND(((curr.price_index - prev.price_index) / prev.price_index * 100), 2) AS calculated_quarterly_change,
        ABS(curr.quarterly_change_pct - 
            ROUND(((curr.price_index - prev.price_index) / prev.price_index * 100), 2)
        ) AS difference
    FROM dbo.european_housing_prices_clean curr
    LEFT JOIN dbo.european_housing_prices_clean prev
        ON curr.country = prev.country
        AND (
            (curr.year = prev.year AND curr.quarter_num = prev.quarter_num + 1)
            OR (curr.year = prev.year + 1 AND curr.quarter_num = 1 AND prev.quarter_num = 4)
        )
    WHERE curr.price_index IS NOT NULL 
      AND prev.price_index IS NOT NULL
      AND curr.country_type = 'Individual'
)
SELECT *
FROM quarterly_comparison
WHERE ABS(reported_quarterly_change - calculated_quarterly_change) > 0.1
ORDER BY difference DESC;
-- Result: 0 errors found - All calculations are accurate! ✓


-- ============================================================================
-- DATA QUALITY VALIDATION: Yearly Changes
-- ============================================================================
-- Purpose: Verify yearly_change_pct calculations are accurate

WITH yearly_comparison AS (
    SELECT 
        curr.country,
        curr.quarter,
        curr.price_index AS current_price,
        prev.price_index AS year_ago_price,
        curr.yearly_change_pct AS reported_yearly_change,
        ROUND(((curr.price_index - prev.price_index) / prev.price_index * 100), 2) AS calculated_yearly_change,
        ABS(curr.yearly_change_pct - 
            ROUND(((curr.price_index - prev.price_index) / prev.price_index * 100), 2)
        ) AS difference
    FROM dbo.european_housing_prices_clean curr
    LEFT JOIN dbo.european_housing_prices_clean prev
        ON curr.country = prev.country
        AND curr.year = prev.year + 1
        AND curr.quarter_num = prev.quarter_num
    WHERE curr.price_index IS NOT NULL 
      AND prev.price_index IS NOT NULL
      AND curr.country_type = 'Individual'
)
SELECT *
FROM yearly_comparison
WHERE ABS(reported_yearly_change - calculated_yearly_change) > 0.1
ORDER BY difference DESC;
-- Result: 0 errors found - All calculations are accurate! ✓


-- ============================================================================
-- SUMMARY: Phase 1 Findings
-- ============================================================================
/*
DATA QUALITY GRADE: A+

✓ 417 records imported successfully
✓ 35 unique countries (28 individual + 7 aggregates)
✓ Zero duplicate records
✓ Switzerland has 12 NULL price_index values (acceptable partial data)
✓ All quarterly_change_pct calculations verified accurate
✓ All yearly_change_pct calculations verified accurate
✓ Negative quarterly changes present (normal market behavior)

ISSUES RESOLVED:
- Character encoding: "Türkiye" fixed from "T├╝rkiye"
- Data type: Decimal columns properly sized (10,2)

NEXT PHASE: Business Analysis →
*/
