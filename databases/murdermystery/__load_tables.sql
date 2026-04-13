COPY public.crime_scene_report FROM '/docker-entrypoint-initdb.d/nycflights/crime_scene_report.txt' DELIMITER '|' CSV HEADER;
COPY public.drivers_license FROM '/docker-entrypoint-initdb.d/nycflights/drivers_license.txt' DELIMITER '|' CSV HEADER;
COPY public.facebook_event_checkin   FROM '/docker-entrypoint-initdb.d/nycflights/facebook_event_checkin.txt'   DELIMITER '|' CSV HEADER;
COPY public.get_fit_now_check_in  FROM '/docker-entrypoint-initdb.d/nycflights/get_fit_now_check_in.txt'  DELIMITER '|' CSV HEADER;
COPY public.get_fit_now_member  FROM '/docker-entrypoint-initdb.d/nycflights/get_fit_now_member.txt'  DELIMITER '|' CSV HEADER;
COPY public.income  FROM '/docker-entrypoint-initdb.d/nycflights/income.txt'  DELIMITER '|' CSV HEADER;
COPY public.interview  FROM '/docker-entrypoint-initdb.d/nycflights/interview.txt'  DELIMITER '|' CSV HEADER;
COPY public.person  FROM '/docker-entrypoint-initdb.d/nycflights/person.txt'  DELIMITER '|' CSV HEADER;