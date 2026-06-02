-- Run from the repo root:
--   duckdb duckdb/nycflights.duckdb -f scripts/nycflights_to_duckdb.sql
--
-- Note: flights.tailnum FK to planes is intentionally omitted. The nycflights13
-- dataset includes synthetic placeholder tailnums (e.g. N3XXAA) for flights
-- whose real registrations were unavailable; these are NULLed out below.
-- DuckDB v1.5 does not support ALTER TABLE ADD FOREIGN KEY, so the FK cannot
-- be added after the tailnum cleanup. The data is clean; the constraint is not.
--
-- Note: time_hour stored as VARCHAR — the source format includes a timezone
-- offset (2013-01-01 06:00:00.000000 +00:00) that DuckDB COPY cannot parse
-- as TIMESTAMP. Use STRPTIME(time_hour, '%Y-%m-%d %H:%M:%S.%f %z') to convert.

CREATE TABLE airlines (
    carrier VARCHAR PRIMARY KEY,
    name    VARCHAR
);

CREATE TABLE airports (
    faa   VARCHAR PRIMARY KEY,
    name  VARCHAR,
    lat   DOUBLE,
    lon   DOUBLE,
    alt   INTEGER,
    tz    INTEGER,
    dst   VARCHAR,
    tzone VARCHAR
);

CREATE TABLE planes (
    tailnum      VARCHAR PRIMARY KEY,
    year         INTEGER,
    type         VARCHAR,
    manufacturer VARCHAR,
    model        VARCHAR,
    engines      INTEGER,
    seats        INTEGER,
    speed        INTEGER,
    engine       VARCHAR
);

CREATE TABLE weather (
    origin     VARCHAR REFERENCES airports(faa),
    year       INTEGER,
    month      INTEGER,
    day        INTEGER,
    hour       INTEGER,
    temp       DOUBLE,
    dewp       DOUBLE,
    humid      DOUBLE,
    wind_dir   INTEGER,
    wind_speed DOUBLE,
    wind_gust  DOUBLE,
    precip     DOUBLE,
    pressure   DOUBLE,
    visib      DOUBLE,
    time_hour  VARCHAR,
    PRIMARY KEY (origin, time_hour)
);

CREATE TABLE flights (
    year           INTEGER,
    month          INTEGER,
    day            INTEGER,
    dep_time       INTEGER,
    sched_dep_time INTEGER,
    dep_delay      INTEGER,
    arr_time       INTEGER,
    sched_arr_time INTEGER,
    arr_delay      INTEGER,
    carrier        VARCHAR REFERENCES airlines(carrier),
    flight         INTEGER,
    tailnum        VARCHAR,
    origin         VARCHAR REFERENCES airports(faa),
    dest           VARCHAR REFERENCES airports(faa),
    air_time       INTEGER,
    distance       INTEGER,
    hour           INTEGER,
    minute         INTEGER,
    time_hour      VARCHAR,
    PRIMARY KEY (year, month, day, carrier, flight, origin)
);

COPY airlines FROM 'databases/nycflights/airlines.csv' (DELIMITER ',', HEADER false);
COPY airports FROM 'databases/nycflights/airports.csv' (DELIMITER ',', HEADER false);
COPY planes   FROM 'databases/nycflights/planes.csv'   (DELIMITER ',', HEADER false);
COPY weather  FROM 'databases/nycflights/weather.csv'  (DELIMITER ',', HEADER false);
COPY flights  FROM 'databases/nycflights/flights.csv'  (DELIMITER ',', HEADER false);

-- NULL out synthetic placeholder tailnums that have no matching planes record
UPDATE flights SET tailnum = NULL
WHERE tailnum IS NOT NULL AND tailnum NOT IN (SELECT tailnum FROM planes);
