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
CREATE TABLE public.weather (
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
    time_hour TIMESTAMP
);

-- flights
CREATE TABLE public.flights (
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
    time_hour TIMESTAMP
);