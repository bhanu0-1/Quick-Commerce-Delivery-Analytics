-- =========================================================
-- Q-Commerce Delivery Operations & Pricing Analytics
-- Step 2: Star Schema Creation
-- =========================================================
-- Design: one fact table (fact_orders) + three dimension
-- tables (dim_company, dim_city, dim_category).
-- Payment_Method is left in fact_orders directly since it
-- only has 5 low-cardinality values and isn't a business
-- dimension we need to analyze/filter heavily on its own.
-- =========================================================

-- Clean slate if re-running this script
DROP TABLE IF EXISTS fact_orders;
DROP TABLE IF EXISTS dim_company;
DROP TABLE IF EXISTS dim_city;
DROP TABLE IF EXISTS dim_category;

-- ---------------------------------------------------------
-- Dimension: Company (the 8 quick-commerce platforms)
-- ---------------------------------------------------------
CREATE TABLE dim_company (
    company_id   SERIAL PRIMARY KEY,   -- SERIAL = auto-increment, like AUTO_INCREMENT in MySQL
    company_name VARCHAR(50) UNIQUE NOT NULL
);

-- ---------------------------------------------------------
-- Dimension: City
-- ---------------------------------------------------------
CREATE TABLE dim_city (
    city_id   SERIAL PRIMARY KEY,
    city_name VARCHAR(50) UNIQUE NOT NULL
);

-- ---------------------------------------------------------
-- Dimension: Product Category
-- ---------------------------------------------------------
CREATE TABLE dim_category (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL
);

-- ---------------------------------------------------------
-- Fact table: one row per order
-- ---------------------------------------------------------
CREATE TABLE fact_orders (
    order_id                 INTEGER PRIMARY KEY,
    company_id                INTEGER REFERENCES dim_company(company_id),
    city_id                    INTEGER REFERENCES dim_city(city_id),
    category_id                INTEGER REFERENCES dim_category(category_id),
    customer_age               SMALLINT NOT NULL,
    order_value                 NUMERIC(10,2) NOT NULL,
    delivery_time_min           NUMERIC(5,1) NOT NULL,
    distance_km                 NUMERIC(5,2) NOT NULL,
    items_count                  SMALLINT NOT NULL,
    payment_method               VARCHAR(30) NOT NULL,
    customer_rating               NUMERIC(3,1),        -- nullable: we chose not to impute
    discount_applied               BOOLEAN NOT NULL,
    delivery_partner_rating         NUMERIC(3,1)        -- nullable: we chose not to impute
);

-- Helpful indexes for the window-function queries we'll run next
CREATE INDEX idx_fact_orders_company ON fact_orders(company_id);
CREATE INDEX idx_fact_orders_city ON fact_orders(city_id);
CREATE INDEX idx_fact_orders_category ON fact_orders(category_id);
