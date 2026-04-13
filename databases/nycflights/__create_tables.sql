CREATE SCHEMA IF NOT EXISTS public;

-- airlines
CREATE TABLE public.airlines (
    carrier VARCHAR(2) PRIMARY KEY,
    name VARCHAR(100)
);

-- airports
CREATE TABLE public.airports (
    faa VARCHAR(3) PRIMARY KEY,
    name VARCHAR(200),
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION,
    alt INTEGER,
    tz INTEGER,
    dst VARCHAR(1),
    tzone VARCHAR(50)
);

-- planes
CREATE TABLE public.planes (
    tailnum VARCHAR(10) PRIMARY KEY,
    year INTEGER,
    type VARCHAR(50),
    manufacturer VARCHAR(100),
    model VARCHAR(100),
    engines INTEGER,
    seats INTEGER,
    speed INTEGER,
    engine VARCHAR(50)
);

-- weather
-- PK uses (origin, time_hour) rather than (origin, year, month, day, hour) because
-- the DST fall-back on 2013-11-03 produces two legitimate hour=1 observations at LGA
-- that are only distinguishable by their UTC time_hour value.
CREATE TABLE public.weather (
    PRIMARY KEY (origin, time_hour),
    origin VARCHAR(3),
    year INTEGER,
    month INTEGER,
    day INTEGER,
    hour INTEGER,
    temp DOUBLE PRECISION,
    dewp DOUBLE PRECISION,
    humid DOUBLE PRECISION,
    wind_dir INTEGER,
    wind_speed DOUBLE PRECISION,
    wind_gust DOUBLE PRECISION,
    precip DOUBLE PRECISION,
    pressure DOUBLE PRECISION,
    visib DOUBLE PRECISION,
    time_hour TIMESTAMP,
    CONSTRAINT fk_weather_origin
        FOREIGN KEY (origin) REFERENCES public.airports (faa)
);

-- flights
-- tailnum is intentionally not a FK to planes. The nycflights13 dataset uses
-- synthetic placeholder tailnums (e.g. N3XXAA, N5XXMQ) for aircraft whose real
-- registrations were unavailable. These do not exist in the FAA registry and
-- cannot be matched to real planes records, so the FK cannot be fully enforced.
CREATE TABLE public.flights (
    PRIMARY KEY (year, month, day, carrier, flight, origin),
    year INTEGER,
    month INTEGER,
    day INTEGER,
    dep_time INTEGER,
    sched_dep_time INTEGER,
    dep_delay INTEGER,
    arr_time INTEGER,
    sched_arr_time INTEGER,
    arr_delay INTEGER,
    carrier VARCHAR(2),
    flight INTEGER,
    tailnum VARCHAR(10),
    origin VARCHAR(3),
    dest VARCHAR(3),
    air_time INTEGER,
    distance INTEGER,
    hour INTEGER,
    minute INTEGER,
    time_hour TIMESTAMP,
    CONSTRAINT fk_flights_carrier
        FOREIGN KEY (carrier) REFERENCES public.airlines (carrier),
    CONSTRAINT fk_flights_origin
        FOREIGN KEY (origin) REFERENCES public.airports (faa),
    CONSTRAINT fk_flights_dest
        FOREIGN KEY (dest) REFERENCES public.airports (faa)
);