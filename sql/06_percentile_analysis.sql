-- =========================================================
-- Step 3.1: PERCENTILE_CONT — median & P90 delivery time
-- per platform
-- =========================================================
-- WITHIN GROUP (ORDER BY ...) tells PostgreSQL what column
-- to sort by before finding the percentile position.
-- 0.5 = median (50th percentile), 0.9 = 90th percentile
-- (i.e. "9 out of 10 orders deliver faster than this")
-- =========================================================

SELECT
    c.company_name,
    COUNT(*) AS total_orders,
    ROUND(AVG(f.delivery_time_min), 1) AS avg_delivery_time,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY f.delivery_time_min) AS median_delivery_time,
    PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY f.delivery_time_min) AS p90_delivery_time
FROM fact_orders f
JOIN dim_company c ON f.company_id = c.company_id
GROUP BY c.company_name
ORDER BY median_delivery_time;
