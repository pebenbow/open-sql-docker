-- Run from the repo root:
--   duckdb duckdb/actors.duckdb -f scripts/actors_to_duckdb.sql

CREATE TABLE actors (
    actor_id             INTEGER     PRIMARY KEY,
    first_name           VARCHAR     NOT NULL,
    last_name            VARCHAR     NOT NULL,
    birth_name           VARCHAR,
    sex                  CHAR(1)     NOT NULL,
    birth_date           DATE        NOT NULL,
    death_date           DATE,
    birth_country        VARCHAR     NOT NULL,
    height_cm            SMALLINT,
    oscar_nominations    SMALLINT    NOT NULL DEFAULT 0,
    oscar_wins           SMALLINT    NOT NULL DEFAULT 0,
    primary_genre        VARCHAR     NOT NULL,
    has_honorary_oscar   BOOLEAN     NOT NULL DEFAULT false,
    notable_role         VARCHAR,
    total_box_office_usd DECIMAL(12,0),
    CHECK (oscar_wins <= oscar_nominations)
);

COPY actors FROM 'databases/actors/actors.csv' (DELIMITER ',', HEADER false);
