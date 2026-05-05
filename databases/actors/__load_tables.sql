COPY public.actors FROM '/docker-entrypoint-initdb.d/actors/actors.csv' DELIMITER ',' CSV;
