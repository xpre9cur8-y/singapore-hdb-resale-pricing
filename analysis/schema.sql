-- schema.sql
-- hdb_resale transaction table
-- VARCHAR as safety buffer (raw API)

CREATE TABLE IF NOT EXISTS resale_transactions (
    _id                 VARCHAR(10),
    month               VARCHAR(7),
    town                VARCHAR(60),
    flat_type           VARCHAR(20),
    block               VARCHAR(10),
    street_name         VARCHAR(100),
    storey_range        VARCHAR(20),
    floor_area_sqm      VARCHAR(10),
    flat_model          VARCHAR(50),
    lease_commence_date VARCHAR(4),
    remaining_lease     VARCHAR(30),
    resale_price        VARCHAR(20)
);

-- import 
-- convert to appropriate data types

ALTER TABLE resale_transactions
ALTER COLUMN _id SET DATA TYPE INTEGER USING _id::INTEGER;

ALTER TABLE resale_transactions
ALTER COLUMN month SET DATA TYPE DATE USING (month || '-01')::DATE;

ALTER TABLE resale_transactions
ALTER COLUMN floor_area_sqm SET DATA TYPE NUMERIC USING floor_area_sqm::NUMERIC;

ALTER TABLE resale_transactions
ALTER COLUMN lease_commence_date SET DATA TYPE INTEGER USING lease_commence_date::INTEGER;

ALTER TABLE resale_transactions
ALTER COLUMN resale_price SET DATA TYPE NUMERIC USING resale_price::NUMERIC;

/* */