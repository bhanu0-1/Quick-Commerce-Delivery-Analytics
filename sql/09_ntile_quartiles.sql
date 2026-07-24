-- =========================================================
-- Step 3.4: NTILE() — segment orders into value quartiles
-- Then check: does discount usage differ by quartile?
-- =========================================================
-- NTILE(4) OVER (ORDER BY order_value) splits ALL 1M orders
-- into 4 equal-sized buckets based on order_value, lowest to
-- highest. Bucket 1 = cheapest 25% of orders, Bucket 4 =
-- priciest 25% of orders.
-- =========================================================

WITH order_quartiles AS (
    SELECT
        order_id,
        order_value,
        discount_applied,
        NTILE(4) OVER (ORDER BY order_value) AS value_quartile
    FROM fact_orders
)
SELECT
    value_quartile,
    COUNT(*) AS num_orders,
    ROUND(MIN(order_value), 2) AS min_value_in_bucket,
    ROUND(MAX(order_value), 2) AS max_value_in_bucket,
    ROUND(100.0 * SUM(CASE WHEN discount_applied THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_orders_discounted
FROM order_quartiles
GROUP BY value_quartile
ORDER BY value_quartile;
