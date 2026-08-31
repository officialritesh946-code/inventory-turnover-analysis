-- Task 19: Inventory Turnover Analysis
-- SQL dialect: PostgreSQL
-- Source table expected: inventory_data
-- The source dataset does not contain COGS. Therefore this project uses a
-- units-based inventory turnover metric for stock-movement analysis:
--   Turnover Ratio = SUM(units_sold) / AVG(inventory_level)
--   Annualized Turnover = Turnover Ratio / observation_years
-- This should NOT be presented as accounting/financial inventory turnover.

-- 1) Data quality check
SELECT
    COUNT(*) AS row_count,
    COUNT(*) FILTER (WHERE date IS NULL) AS null_dates,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS null_products,
    COUNT(*) FILTER (WHERE inventory_level IS NULL) AS null_inventory,
    COUNT(*) FILTER (WHERE units_sold IS NULL) AS null_units_sold,
    COUNT(*) FILTER (WHERE inventory_level < 0) AS negative_inventory,
    COUNT(*) FILTER (WHERE units_sold < 0) AS negative_units_sold
FROM inventory_data;

-- 2) Overall inventory turnover
WITH period AS (
    SELECT
        MIN(date)::date AS start_date,
        MAX(date)::date AS end_date,
        (MAX(date)::date - MIN(date)::date + 1) / 365.25 AS years
    FROM inventory_data
)
SELECT
    SUM(i.units_sold) AS total_units_sold,
    AVG(i.inventory_level) AS average_inventory,
    SUM(i.units_sold) / NULLIF(AVG(i.inventory_level), 0) AS turnover_ratio,
    (SUM(i.units_sold) / NULLIF(AVG(i.inventory_level), 0)) / NULLIF(p.years, 0)
        AS annualized_turnover
FROM inventory_data i
CROSS JOIN period p
GROUP BY p.years;

-- 3) Turnover table by category
WITH period AS (
    SELECT
        (MAX(date)::date - MIN(date)::date + 1) / 365.25 AS years
    FROM inventory_data
)
SELECT
    category,
    COUNT(DISTINCT product_id) AS product_count,
    SUM(units_sold) AS total_units_sold,
    AVG(inventory_level) AS average_inventory,
    SUM(units_sold) / NULLIF(AVG(inventory_level), 0) AS turnover_ratio,
    (SUM(units_sold) / NULLIF(AVG(inventory_level), 0)) / NULLIF(p.years, 0)
        AS annualized_turnover,
    SUM(units_sold) / NULLIF(SUM(units_ordered), 0) AS sell_through_vs_orders,
    SUM(CASE WHEN inventory_level = 0 THEN 1 ELSE 0 END) AS stockout_days
FROM inventory_data
CROSS JOIN period p
GROUP BY category, p.years
ORDER BY annualized_turnover DESC;

-- 4) Product-category turnover table
WITH period AS (
    SELECT
        (MAX(date)::date - MIN(date)::date + 1) / 365.25 AS years
    FROM inventory_data
)
SELECT
    product_id,
    category,
    COUNT(DISTINCT date) AS observation_days,
    SUM(units_sold) AS total_units_sold,
    AVG(inventory_level) AS average_inventory,
    SUM(units_sold) / NULLIF(AVG(inventory_level), 0) AS turnover_ratio,
    (SUM(units_sold) / NULLIF(AVG(inventory_level), 0)) / NULLIF(p.years, 0)
        AS annualized_turnover,
    SUM(units_sold) / NULLIF(SUM(units_ordered), 0) AS sell_through_vs_orders,
    SUM(CASE WHEN inventory_level = 0 THEN 1 ELSE 0 END) AS stockout_days
FROM inventory_data
CROSS JOIN period p
GROUP BY product_id, category, p.years
ORDER BY annualized_turnover ASC;

-- 5) Slow-mover list using the bottom quartile of annualized turnover
WITH period AS (
    SELECT (MAX(date)::date - MIN(date)::date + 1) / 365.25 AS years
    FROM inventory_data
),
product_turnover AS (
    SELECT
        product_id,
        category,
        COUNT(DISTINCT date) AS observation_days,
        SUM(units_sold) AS total_units_sold,
        AVG(inventory_level) AS average_inventory,
        (SUM(units_sold) / NULLIF(AVG(inventory_level), 0)) / NULLIF(p.years, 0)
            AS annualized_turnover
    FROM inventory_data
    CROSS JOIN period p
    GROUP BY product_id, category, p.years
),
ranked AS (
    SELECT *,
           NTILE(4) OVER (ORDER BY annualized_turnover ASC) AS turnover_quartile
    FROM product_turnover
)
SELECT
    product_id,
    category,
    observation_days,
    total_units_sold,
    average_inventory,
    annualized_turnover,
    CASE
        WHEN turnover_quartile = 1 THEN 'Slow Mover'
        ELSE 'Normal'
    END AS movement_class
FROM ranked
WHERE turnover_quartile = 1
ORDER BY annualized_turnover ASC;

-- 6) Monthly stock movement trend
SELECT
    DATE_TRUNC('month', date)::date AS month,
    SUM(units_sold) AS total_units_sold,
    AVG(inventory_level) AS average_inventory,
    SUM(units_sold) / NULLIF(AVG(inventory_level), 0) AS monthly_turnover,
    SUM(CASE WHEN inventory_level = 0 THEN 1 ELSE 0 END) AS stockout_days
FROM inventory_data
GROUP BY DATE_TRUNC('month', date)
ORDER BY month;
