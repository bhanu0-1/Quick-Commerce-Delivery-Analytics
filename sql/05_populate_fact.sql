-- =========================================================
-- Step 2.5d: Populate fact_orders
-- Join staging_orders to the dimension tables to convert
-- text (company/city/category) into their IDs, then insert
-- everything into the real fact table.
-- =========================================================

INSERT INTO fact_orders (
    order_id, company_id, city_id, category_id,
    customer_age, order_value, delivery_time_min, distance_km,
    items_count, payment_method, customer_rating,
    discount_applied, delivery_partner_rating
)
SELECT
    s.order_id,
    c.company_id,
    ci.city_id,
    cat.category_id,
    s.customer_age,
    s.order_value,
    s.delivery_time_min,
    s.distance_km,
    s.items_count,
    s.payment_method,
    s.customer_rating,
    s.discount_applied,
    s.delivery_partner_rating
FROM staging_orders s
JOIN dim_company c   ON s.company = c.company_name
JOIN dim_city ci      ON s.city = ci.city_name
JOIN dim_category cat ON s.product_category = cat.category_name;

-- Verify: should be ~1,000,000 (matches staging_orders count)
SELECT COUNT(*) AS total_orders FROM fact_orders;

-- Sanity check: join back to dimension tables to confirm
-- readable names come back correctly
SELECT
    f.order_id, c.company_name, ci.city_name, cat.category_name,
    f.order_value, f.delivery_time_min
FROM fact_orders f
JOIN dim_company c ON f.company_id = c.company_id
JOIN dim_city ci ON f.city_id = ci.city_id
JOIN dim_category cat ON f.category_id = cat.category_id
LIMIT 5;
