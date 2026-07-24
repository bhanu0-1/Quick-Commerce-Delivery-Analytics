-- =========================================================
-- Step 2.5a: Staging table
-- Matches the cleaned flat CSV exactly (text columns, no IDs).
-- This is a temporary landing zone before we split the data
-- into the star schema.
-- =========================================================

DROP TABLE IF EXISTS staging_orders;

CREATE TABLE staging_orders (
    order_id                 INTEGER,
    company                  VARCHAR(50),
    city                     VARCHAR(50),
    customer_age             SMALLINT,
    order_value              NUMERIC(10,2),
    delivery_time_min        NUMERIC(5,1),
    distance_km              NUMERIC(5,2),
    items_count               SMALLINT,
    product_category          VARCHAR(50),
    payment_method             VARCHAR(30),
    customer_rating             NUMERIC(3,1),   -- nullable
    discount_applied             BOOLEAN,
    delivery_partner_rating       NUMERIC(3,1)   -- nullable
);
