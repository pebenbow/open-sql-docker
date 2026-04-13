COPY public.crime_scene_report FROM '/docker-entrypoint-initdb.d/murdermystery/crime_scene_report.txt' DELIMITER '|' CSV;
COPY public.drivers_license FROM '/docker-entrypoint-initdb.d/murdermystery/drivers_license.txt' DELIMITER '|' CSV;
COPY public.person FROM '/docker-entrypoint-initdb.d/murdermystery/person.txt' DELIMITER '|' CSV;
COPY public.get_fit_now_member FROM '/docker-entrypoint-initdb.d/murdermystery/get_fit_now_member.txt' DELIMITER '|' CSV;
COPY public.get_fit_now_check_in FROM '/docker-entrypoint-initdb.d/murdermystery/get_fit_now_check_in.txt' DELIMITER '|' CSV;
COPY public.income FROM '/docker-entrypoint-initdb.d/murdermystery/income.txt' DELIMITER '|' CSV;
COPY public.interview FROM '/docker-entrypoint-initdb.d/murdermystery/interview.txt' DELIMITER '|' CSV;
COPY public.facebook_event_checkin FROM '/docker-entrypoint-initdb.d/murdermystery/facebook_event_checkin.txt' DELIMITER '|' CSV;