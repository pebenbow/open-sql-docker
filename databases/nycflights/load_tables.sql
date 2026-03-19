COPY public.airlines FROM '/data/airlines.csv' DELIMITER ',' CSV HEADER;
COPY public.airports FROM '/data/airports.csv' DELIMITER ',' CSV HEADER;
COPY public.planes   FROM '/data/planes.csv'   DELIMITER ',' CSV HEADER;
COPY public.weather  FROM '/data/weather.csv'  DELIMITER ',' CSV HEADER;
COPY public.flights  FROM '/data/flights.csv'  DELIMITER ',' CSV HEADER;