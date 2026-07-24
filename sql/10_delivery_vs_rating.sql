-- =========================================================
-- Step 3.5: Delivery speed vs. customer rating
-- Uses CASE WHEN to bucket delivery time into readable
-- ranges, then averages rating per bucket.
-- Note: customer_rating has NULLs (we chose not to impute
-- these back in Step 1) — AVG() automatically ignores NULLs,
-- so this stays statistically honest.
-- =========================================================

SELECT
    CASE
        WHEN delivery_time_min < 10 THEN '1. Under 10 min'
        WHEN delivery_time_min < 15 THEN '2. 10-15 min'
        WHEN delivery_time_min < 20 THEN '3. 15-20 min'
        WHEN delivery_time_min < 25 THEN '4. 20-25 min'
        ELSE '5. 25+ min'
    END AS delivery_time_bucket,
    COUNT(*) AS num_orders,
    COUNT(customer_rating) AS num_rated_orders,
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating
FROM fact_orders
GROUP BY delivery_time_bucket
ORDER BY delivery_time_bucket;
