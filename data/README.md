# Data

## European Housing Prices Dataset

### File
- `european_housing_prices_clean.csv` - Main dataset (417 records)

### Data Dictionary

**Columns:**
- `country` - Country name (28 individual + 7 aggregate regions)
- `country_type` - "Individual" or "Aggregate"
- `eu_member` - EU membership status (Yes/No/N/A)
- `eurozone_member` - Eurozone membership status (Yes/No/N/A)
- `year` - Year (2022-2025)
- `quarter_num` - Quarter number (1-4)
- `quarter` - Quarter label (e.g., "2023-Q1")
- `price_index` - Price index (2015 = 100 baseline)
- `quarterly_change_pct` - Quarter-over-quarter change (%)
- `yearly_change_pct` - Year-over-year change (%)
- `price_change_since_2015_pct` - Cumulative change since 2015 (%)

### Data Source
European housing price statistics covering Q4 2022 through Q3 2025.

### Notes
- Switzerland has NULL values for `price_index` (12 records)
- Türkiye data ends at 2024-Q4 (no 2025 data)
- All calculations verified for accuracy (zero errors)

### Data Quality: A+
✓ No duplicates
✓ Accurate calculations
✓ Consistent formatting
```


