CREATE SCHEMA IF NOT EXISTS public;

create table if not exists public.drivers_license
(
    id           serial
        primary key,
    age          integer,
    height       integer,
    eye_color    varchar(10),
    hair_color   varchar(10),
    gender       varchar(10),
    plate_number varchar(10),
    car_make     varchar(20),
    car_model    varchar(20)
);

alter table public.drivers_license
    owner to postgres;

create table if not exists public.person
(
    id                  serial
        primary key,
    name                varchar(50),
    license_id          integer
        references public.drivers_license,
    address_number      integer,
    address_street_name varchar(50),
    ssn                 integer
        unique
);

alter table public.person
    owner to postgres;

create table if not exists public.crime_scene_report
(
    id          serial
        primary key,
    date        date,
    type        varchar(20),
    description text,
    city        varchar(20)
);

alter table public.crime_scene_report
    owner to postgres;

create table if not exists public.interview
(
    person_id  integer not null
        primary key
        references public.person,
    transcript text
);

alter table public.interview
    owner to postgres;

create table if not exists public.get_fit_now_member
(
    id                    varchar(10) not null
        primary key,
    person_id             integer
        references public.person,
    name                  varchar(50),
    membership_start_date date,
    membership_status     varchar(10)
);

alter table public.get_fit_now_member
    owner to postgres;

create table if not exists public.get_fit_now_check_in
(
    id             serial
        primary key,
    membership_id  varchar(10)
        references public.get_fit_now_member,
    check_in_date  date,
    check_in_time  time,
    check_out_time time
);

alter table public.get_fit_now_check_in
    owner to postgres;

create table if not exists public.income
(
    ssn           integer not null
        primary key
        references public.person (ssn),
    annual_income integer
);

alter table public.income
    owner to postgres;

create table if not exists public.facebook_event_checkin
(
    id         serial
        primary key,
    person_id  integer
        references public.person,
    event_id   integer,
    event_name varchar(100),
    date       date
);

alter table public.facebook_event_checkin
    owner to postgres;

