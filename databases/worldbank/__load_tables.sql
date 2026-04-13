COPY public.countries   FROM '/docker-entrypoint-initdb.d/worldbank/countries.txt'  DELIMITER '|' CSV;
COPY public.series      FROM '/docker-entrypoint-initdb.d/worldbank/series.txt'      DELIMITER '|' CSV;
COPY public.indicators  FROM '/docker-entrypoint-initdb.d/worldbank/indicators.txt'  DELIMITER '|' CSV;
