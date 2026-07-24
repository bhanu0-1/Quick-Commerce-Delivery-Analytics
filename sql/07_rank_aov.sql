-- =========================================================
-- Step 3.2: RANK() — true window function, uses OVER()
-- Ranking platforms by average order value (AOV)
-- =========================================================
-- Difference from Step 3.1: this still needs an aggregate
-- (AVG) per company first via GROUP BY, but RANK() then
-- ranks those aggregated results using OVER(ORDER BY ...)
-- =========================================================

SELECT
    c.company_name,
    ROUND(AVG(f.order_value), 2) AS avg_order_value,
    RANK() OVER (ORDER BY AVG(f.order_value) DESC) AS aov_rank
FROM fact_orders f
JOIN dim_company c ON f.company_id = c.company_id
GROUP BY c.company_name
ORDER BY aov_rank;
