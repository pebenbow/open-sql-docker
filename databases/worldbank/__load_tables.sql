COPY public.regions       FROM '/docker-entrypoint-initdb.d/worldbank/regions.txt'       DELIMITER '|' CSV;
COPY public.income_groups FROM '/docker-entrypoint-initdb.d/worldbank/income_groups.txt' DELIMITER '|' CSV;
COPY public.lending_types FROM '/docker-entrypoint-initdb.d/worldbank/lending_types.txt' DELIMITER '|' CSV;
COPY public.countries     FROM '/docker-entrypoint-initdb.d/worldbank/countries.txt'     DELIMITER '|' CSV;
COPY public.series        FROM '/docker-entrypoint-initdb.d/worldbank/series.txt'        DELIMITER '|' CSV;
COPY public.indicators    FROM '/docker-entrypoint-initdb.d/worldbank/indicators.txt'    DELIMITER '|' CSV;
