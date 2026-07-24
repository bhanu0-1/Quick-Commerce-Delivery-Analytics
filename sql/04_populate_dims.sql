-- =========================================================
-- Step 2.5c: Populate dimension tables
-- Pull the unique values out of staging_orders into each
-- small lookup table. DISTINCT ensures no duplicates.
-- =========================================================

INSERT INTO dim_company (company_name)
SELECT DISTINCT company
FROM staging_orders
ORDER BY company;

INSERT INTO dim_city (city_name)
SELECT DISTINCT city
FROM staging_orders
ORDER BY city;

INSERT INTO dim_category (category_name)
SELECT DISTINCT product_category
FROM staging_orders
ORDER BY product_category;

-- Quick check: row counts should match what you found earlier
-- (8 companies, 13 cities incl. "Unknown", 7 categories)
SELECT 'dim_company' AS table_name, COUNT(*) FROM dim_company
UNION ALL
SELECT 'dim_city', COUNT(*) FROM dim_city
UNION ALL
SELECT 'dim_category', COUNT(*) FROM dim_category;
