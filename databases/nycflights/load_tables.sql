COPY public.airlines FROM '/docker-entrypoint-initdb.d/nycflights/airlines.csv' DELIMITER ',' CSV HEADER;
COPY public.airports FROM '/docker-entrypoint-initdb.d/nycflights/airports.csv' DELIMITER ',' CSV HEADER;
COPY public.planes   FROM '/docker-entrypoint-initdb.d/nycflights/planes.csv'   DELIMITER ',' CSV HEADER;
COPY public.weather  FROM '/docker-entrypoint-initdb.d/nycflights/weather.csv'  DELIMITER ',' CSV HEADER;
COPY public.flights  FROM '/docker-entrypoint-initdb.d/nycflights/flights.csv'  DELIMITER ',' CSV HEADER;