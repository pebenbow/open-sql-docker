COPY public.airlines FROM 'airlines.csv' DELIMITER ',' CSV HEADER;
COPY public.airports FROM 'airports.csv' DELIMITER ',' CSV HEADER;
COPY public.planes   FROM 'planes.csv'   DELIMITER ',' CSV HEADER;
COPY public.weather  FROM 'weather.csv'  DELIMITER ',' CSV HEADER;
COPY public.flights  FROM 'flights.csv'  DELIMITER ',' CSV HEADER;