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

-- Self-check function for the SQL Murder Mystery narrative. Not part of the
-- original NUKnightLab project (which verifies answers via an INSERT into a
-- solution table instead) - added here so students get instant feedback
-- without needing a separate answer-checking table. The case is designed as
-- a two-stage reveal: the first correct name (the shooter) confirms the
-- immediate suspect but points toward a second, deeper answer (the person
-- who hired him).
create or replace function public.check_murderer(suspect varchar)
returns varchar as $$
begin
    if lower(suspect) = lower('Jeremy Bowers') then
        return 'Congratulations, you found the murderer! But wait, there''s more... '
            || 'If you think you''re up for a challenge, try querying the interview '
            || 'transcript of the murderer to find the real villain behind this crime.';
    elsif lower(suspect) = lower('Miranda Priestly') then
        return 'Congratulations, you found the real mastermind behind the murder! '
            || 'You have completed the SQL Murder Mystery. Great job!';
    else
        return 'That''s not the right person. Keep investigating!';
    end if;
end;
$$ language plpgsql;

alter function public.check_murderer(varchar)
    owner to postgres;

