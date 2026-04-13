CREATE SCHEMA IF NOT EXISTS public;

-- countries
CREATE TABLE public.countries (
    id INTEGER PRIMARY KEY,
    country_code VARCHAR(3) UNIQUE NOT NULL,
    iso2_code VARCHAR(2),
    short_name VARCHAR(100),
    region VARCHAR(100),
    capital VARCHAR(100),
    longitude DOUBLE PRECISION,
    latitude DOUBLE PRECISION,
    income_group VARCHAR(50),
    lending_type VARCHAR(50)
);

-- series
CREATE TABLE public.series (
    id INTEGER PRIMARY KEY,
    indicator_code VARCHAR(20) UNIQUE NOT NULL,
    indicator_name VARCHAR(200),
    description TEXT,
    source VARCHAR(100),
    source_org TEXT
);

-- indicators
CREATE TABLE public.indicators (
    PRIMARY KEY (country_id, year),
    id INTEGER,
    country_id INTEGER NOT NULL,
    year INTEGER NOT NULL,
    pct_agricultural_land DOUBLE PRECISION,
    pct_arable_land DOUBLE PRECISION,
    pct_forest_area DOUBLE PRECISION,
    rural_land_area_km2 DOUBLE PRECISION,
    urban_land_area_km2 DOUBLE PRECISION,
    land_area_km2 DOUBLE PRECISION,
    population BIGINT,
    gdp_usd DOUBLE PRECISION,
    gdp_per_capita_usd DOUBLE PRECISION,
    CONSTRAINT fk_indicators_country
        FOREIGN KEY (country_id) REFERENCES public.countries (id)
);
