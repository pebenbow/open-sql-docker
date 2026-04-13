COPY public.airlines FROM '/docker-entrypoint-initdb.d/nycflights/airlines.csv' DELIMITER ',' CSV;
COPY public.airports FROM '/docker-entrypoint-initdb.d/nycflights/airports.csv' DELIMITER ',' CSV;
COPY public.planes   FROM '/docker-entrypoint-initdb.d/nycflights/planes.csv'   DELIMITER ',' CSV;
COPY public.weather  FROM '/docker-entrypoint-initdb.d/nycflights/weather.csv'  DELIMITER ',' CSV;
COPY public.flights  FROM '/docker-entrypoint-initdb.d/nycflights/flights.csv'  DELIMITER ',' CSV;

-- NULL out synthetic placeholder tailnums that have no matching planes record,
-- then enforce the FK. The nycflights13 dataset uses fabricated N-numbers
-- (e.g. N3XXAA, N5XXMQ) for aircraft whose real registrations were unavailable;
-- these do not represent real aircraft and are set to NULL here.
UPDATE public.flights
SET tailnum = NULL
WHERE tailnum IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM public.planes p WHERE p.tailnum = flights.tailnum
  );

ALTER TABLE public.flights
    ADD CONSTRAINT fk_flights_tailnum
    FOREIGN KEY (tailnum) REFERENCES public.planes (tailnum);