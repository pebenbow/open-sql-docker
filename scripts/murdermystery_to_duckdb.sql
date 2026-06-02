-- Run from the repo root:
--   duckdb duckdb/murdermystery.duckdb -f scripts/murdermystery_to_duckdb.sql

CREATE TABLE drivers_license (
    id           INTEGER PRIMARY KEY,
    age          INTEGER,
    height       INTEGER,
    eye_color    VARCHAR,
    hair_color   VARCHAR,
    gender       VARCHAR,
    plate_number VARCHAR,
    car_make     VARCHAR,
    car_model    VARCHAR
);

CREATE TABLE person (
    id                  INTEGER PRIMARY KEY,
    name                VARCHAR,
    license_id          INTEGER REFERENCES drivers_license(id),
    address_number      INTEGER,
    address_street_name VARCHAR,
    ssn                 INTEGER UNIQUE
);

CREATE TABLE crime_scene_report (
    id          INTEGER PRIMARY KEY,
    date        DATE,
    type        VARCHAR,
    description VARCHAR,
    city        VARCHAR
);

CREATE TABLE interview (
    person_id  INTEGER PRIMARY KEY REFERENCES person(id),
    transcript VARCHAR
);

CREATE TABLE get_fit_now_member (
    id                    VARCHAR PRIMARY KEY,
    person_id             INTEGER REFERENCES person(id),
    name                  VARCHAR,
    membership_start_date DATE,
    membership_status     VARCHAR
);

CREATE TABLE get_fit_now_check_in (
    id             INTEGER PRIMARY KEY,
    membership_id  VARCHAR REFERENCES get_fit_now_member(id),
    check_in_date  DATE,
    check_in_time  TIME,
    check_out_time TIME
);

CREATE TABLE income (
    ssn           INTEGER PRIMARY KEY REFERENCES person(ssn),
    annual_income INTEGER
);

CREATE TABLE facebook_event_checkin (
    id         INTEGER PRIMARY KEY,
    person_id  INTEGER REFERENCES person(id),
    event_id   INTEGER,
    event_name VARCHAR,
    date       DATE
);

COPY drivers_license        FROM 'databases/murdermystery/drivers_license.txt'        (DELIMITER '|', HEADER false);
COPY person                 FROM 'databases/murdermystery/person.txt'                 (DELIMITER '|', HEADER false);
COPY crime_scene_report     FROM 'databases/murdermystery/crime_scene_report.txt'     (DELIMITER '|', HEADER false);
COPY interview              FROM 'databases/murdermystery/interview.txt'              (DELIMITER '|', HEADER false);
COPY get_fit_now_member     FROM 'databases/murdermystery/get_fit_now_member.txt'     (DELIMITER '|', HEADER false);
COPY get_fit_now_check_in   FROM 'databases/murdermystery/get_fit_now_check_in.txt'   (DELIMITER '|', HEADER false);
COPY income                 FROM 'databases/murdermystery/income.txt'                 (DELIMITER '|', HEADER false);
COPY facebook_event_checkin FROM 'databases/murdermystery/facebook_event_checkin.txt' (DELIMITER '|', HEADER false);
