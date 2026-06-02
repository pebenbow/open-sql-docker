-- Run from the repo root:
--   duckdb duckdb/worldbank.duckdb -f scripts/worldbank_to_duckdb.sql

CREATE TABLE regions (
    region_id   SMALLINT PRIMARY KEY,
    name        VARCHAR  NOT NULL UNIQUE
);

CREATE TABLE income_groups (
    income_group_id SMALLINT PRIMARY KEY,
    name            VARCHAR  NOT NULL UNIQUE
);

CREATE TABLE lending_types (
    lending_type_id SMALLINT PRIMARY KEY,
    name            VARCHAR  NOT NULL UNIQUE
);

CREATE TABLE countries (
    id              INTEGER  PRIMARY KEY,
    country_code    VARCHAR  UNIQUE NOT NULL,
    iso2_code       VARCHAR,
    short_name      VARCHAR,
    region_id       SMALLINT REFERENCES regions(region_id),
    capital         VARCHAR,
    longitude       DOUBLE,
    latitude        DOUBLE,
    income_group_id SMALLINT REFERENCES income_groups(income_group_id),
    lending_type_id SMALLINT REFERENCES lending_types(lending_type_id),
    is_aggregate    BOOLEAN  NOT NULL DEFAULT false
);

CREATE TABLE series (
    id             INTEGER PRIMARY KEY,
    indicator_code VARCHAR UNIQUE NOT NULL,
    indicator_name VARCHAR,
    description    VARCHAR,
    source         VARCHAR,
    source_org     VARCHAR
);

CREATE TABLE indicators (
    id                    INTEGER,
    country_id            INTEGER  NOT NULL REFERENCES countries(id),
    year                  INTEGER  NOT NULL,
    pct_agricultural_land DOUBLE,
    pct_arable_land       DOUBLE,
    pct_forest_area       DOUBLE,
    rural_land_area_km2   DOUBLE,
    urban_land_area_km2   DOUBLE,
    land_area_km2         DOUBLE,
    population            BIGINT,
    gdp_usd               DOUBLE,
    gdp_per_capita_usd    DOUBLE,
    PRIMARY KEY (country_id, year)
);

COPY regions       FROM 'databases/worldbank/regions.txt'       (DELIMITER '|', HEADER false);
COPY income_groups FROM 'databases/worldbank/income_groups.txt' (DELIMITER '|', HEADER false);
COPY lending_types FROM 'databases/worldbank/lending_types.txt' (DELIMITER '|', HEADER false);
COPY countries     FROM 'databases/worldbank/countries.txt'     (DELIMITER '|', HEADER false);
COPY series        FROM 'databases/worldbank/series.txt'        (DELIMITER '|', HEADER false);
COPY indicators    FROM 'databases/worldbank/indicators.txt'    (DELIMITER '|', HEADER false);
