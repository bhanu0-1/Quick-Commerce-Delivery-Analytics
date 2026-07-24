-- =========================================================
-- Step 3.3: PARTITION BY — compare each order to its own
-- platform's average, without collapsing rows
-- =========================================================
-- Unlike RANK() above (one row per platform, 8 rows total),
-- this keeps EVERY order as its own row, but adds a column
-- showing that platform's average alongside it.
-- PARTITION BY company_id = "reset the AVG() calculation for
-- each company separately"
-- =========================================================

SELECT
    f.order_id,
    c.company_name,
    f.order_value,
    ROUND(AVG(f.order_value) OVER (PARTITION BY f.company_id), 2) AS company_avg_order_value,
    ROUND(f.order_value - AVG(f.order_value) OVER (PARTITION BY f.company_id), 2) AS diff_from_company_avg
FROM fact_orders f
JOIN dim_company c ON f.company_id = c.company_id
ORDER BY f.order_id
LIMIT 10;
