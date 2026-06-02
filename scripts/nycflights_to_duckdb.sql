-- Run from the repo root:
--   duckdb duckdb/nycflights.duckdb -f scripts/nycflights_to_duckdb.sql

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
    origin     VARCHAR,
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
    carrier        VARCHAR,
    flight         INTEGER,
    tailnum        VARCHAR,
    origin         VARCHAR,
    dest           VARCHAR,
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
