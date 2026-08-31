# Task 19 — Inventory Turnover Analysis

## Objective
Analyze stock movement and identify slow-moving products using Excel and SQL.

## Dataset
- Rows: 76,000
- Columns: 16
- Date range: 2022-01-01 to 2024-01-30
- Stores: 5
- Product IDs: 20
- Categories: 5
- Regions: 4
- Missing values: 0
- Duplicate rows: 0

## Important methodology note
The supplied dataset does **not** contain Cost of Goods Sold (COGS). Traditional financial inventory turnover is:

`COGS / Average Inventory`

To complete the stock-movement task honestly, this project uses a **units-based turnover metric**:

`Turnover Ratio = Total Units Sold / Average Inventory`

`Annualized Turnover = Turnover Ratio / Observation Period in Years`

This measures how frequently the average inventory level is cycled through in unit terms. It should not be described as accounting/financial inventory turnover.

## Slow-mover definition
Slow movers are identified using the **bottom quartile (lowest 25%) of annualized turnover** at the Product ID + Category level. The bottom 10% is additionally labeled **Critical Slow Mover**.

## Key results
- Overall annualized units-based turnover: **10,776.55x**
- Top turnover category: **Groceries**
- Slow-mover combinations: **16**
- Critical slow-mover combinations: **7**
- Observed stockout rows: **406 (0.53%)**

## Deliverables
- `Inventory_Turnover_Analysis.xlsx` — professional Excel workbook with dashboard, turnover tables, slow-mover list, monthly trend, data quality, and methodology.
- `data/turnover_by_category.csv` — category comparison.
- `data/product_turnover_table.csv` — product-category turnover table.
- `data/slow_mover_list.csv` — prioritized slow-mover watchlist.
- `data/monthly_turnover_trend.csv` — monthly stock-movement trend.
- `data/inventory_raw.csv` — original supplied dataset.
- `documentation/inventory_turnover_analysis.sql` — PostgreSQL queries for the analysis.
- `Task_19_Inventory_Turnover_Report.pdf` — concise project report.

## Business interpretation
- Higher turnover generally indicates faster stock movement and more efficient use of inventory.
- Very low turnover can indicate overstocking, weak demand, excessive assortment, or reorder levels that are too high.
- High turnover is **not automatically risk-free**: if inventory is too lean, stockouts can increase and sales may be lost.
- Slow movers should be reviewed before automatic clearance decisions; consider demand trends, promotions, seasonality, and stockout history.

## Recommended GitHub structure
```text
Task_19_Inventory_Turnover_Analysis/
├── README.md
├── Inventory_Turnover_Analysis.xlsx
├── Task_19_Inventory_Turnover_Report.pdf
├── data/
│   ├── inventory_raw.csv
│   ├── turnover_by_category.csv
│   ├── product_turnover_table.csv
│   ├── slow_mover_list.csv
│   └── monthly_turnover_trend.csv
└── documentation/
    └── inventory_turnover_analysis.sql
```
