CREATE SCHEMA IF NOT EXISTS public;

CREATE TABLE public.actors (
    actor_id          INTEGER      PRIMARY KEY,
    first_name        VARCHAR(50)  NOT NULL,
    last_name         VARCHAR(50)  NOT NULL,
    birth_name        VARCHAR(100),
    sex               CHAR(1)      NOT NULL CHECK (sex IN ('M', 'F')),
    birth_date        DATE         NOT NULL,
    death_date        DATE,
    birth_country     VARCHAR(50)  NOT NULL,
    height_cm         SMALLINT,
    oscar_nominations SMALLINT     NOT NULL DEFAULT 0,
    oscar_wins        SMALLINT     NOT NULL DEFAULT 0,
    primary_genre          VARCHAR(20)   NOT NULL,
    has_honorary_oscar     BOOLEAN       NOT NULL DEFAULT false,
    notable_role           TEXT,
    total_box_office_usd   NUMERIC(12,0),
    CONSTRAINT chk_oscar_wins CHECK (oscar_wins <= oscar_nominations)
);
