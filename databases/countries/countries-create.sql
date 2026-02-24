SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: countries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.countries (
    country character varying(200),
    iso2c character varying(2),
    iso3c character varying(3),
    yr integer,
    population bigint,
    area numeric,
    lastupdated date,
    region character varying(200),
    capital character varying(200),
    longitude real,
    latitude real
);


ALTER TABLE public.countries OWNER TO postgres;

--
-- Data for Name: countries; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.countries VALUES ('Afghanistan', 'AF', 'AFG', 2022, 40578842, 652230.0, '2024-12-16', 'South Asia', 'Kabul', 69.1761, 34.5228);
INSERT INTO public.countries VALUES ('Albania', 'AL', 'ALB', 2022, 2777689, 27400.0, '2024-12-16', 'Europe & Central Asia', 'Tirane', 19.8172, 41.3317);
INSERT INTO public.countries VALUES ('Algeria', 'DZ', 'DZA', 2022, 45477389, 2381741.0, '2024-12-16', 'Middle East & North Africa', 'Algiers', 3.05097, 36.7397);
INSERT INTO public.countries VALUES ('American Samoa', 'AS', 'ASM', 2022, 48342, 200.0, '2024-12-16', 'East Asia & Pacific', 'Pago Pago', -170.691, -14.2846);
INSERT INTO public.countries VALUES ('Andorra', 'AD', 'AND', 2022, 79705, 470.0, '2024-12-16', 'Europe & Central Asia', 'Andorra la Vella', 1.5218, 42.5075);
INSERT INTO public.countries VALUES ('Angola', 'AO', 'AGO', 2022, 35635029, 1246700.0, '2024-12-16', 'Sub-Saharan Africa', 'Luanda', 13.242, -8.81155);
INSERT INTO public.countries VALUES ('Antigua and Barbuda', 'AG', 'ATG', 2022, 92840, 440.0, '2024-12-16', 'Latin America & Caribbean', 'Saint John''s', -61.8456, 17.1175);
INSERT INTO public.countries VALUES ('Argentina', 'AR', 'ARG', 2022, 45407904, 2736690.0, '2024-12-16', 'Latin America & Caribbean', 'Buenos Aires', -58.4173, -34.6118);
INSERT INTO public.countries VALUES ('Armenia', 'AM', 'ARM', 2022, 2969200, 28470.0, '2024-12-16', 'Europe & Central Asia', 'Yerevan', 44.509, 40.1596);
INSERT INTO public.countries VALUES ('Aruba', 'AW', 'ABW', 2022, 107310, 180.0, '2024-12-16', 'Latin America & Caribbean', 'Oranjestad', -70.0167, 12.5167);
INSERT INTO public.countries VALUES ('Australia', 'AU', 'AUS', 2022, 26014399, 7692020.0, '2024-12-16', 'East Asia & Pacific', 'Canberra', 149.129, -35.282);
INSERT INTO public.countries VALUES ('Austria', 'AT', 'AUT', 2022, 9041851, 82520.0, '2024-12-16', 'Europe & Central Asia', 'Vienna', 16.3798, 48.2201);
INSERT INTO public.countries VALUES ('Azerbaijan', 'AZ', 'AZE', 2022, 10141756, 82650.0, '2024-12-16', 'Europe & Central Asia', 'Baku', 49.8932, 40.3834);
INSERT INTO public.countries VALUES ('Bahamas, The', 'BS', 'BHS', 2022, 397538, 10010.0, '2024-12-16', 'Latin America & Caribbean', 'Nassau', -77.339, 25.0661);
INSERT INTO public.countries VALUES ('Bahrain', 'BH', 'BHR', 2022, 1524693, 790.0, '2024-12-16', 'Middle East & North Africa', 'Manama', 50.5354, 26.1921);
INSERT INTO public.countries VALUES ('Bangladesh', 'BD', 'BGD', 2022, 169384897, 130170.0, '2024-12-16', 'South Asia', 'Dhaka', 90.4113, 23.7055);
INSERT INTO public.countries VALUES ('Barbados', 'BB', 'BRB', 2022, 282318, 430.0, '2024-12-16', 'Latin America & Caribbean', 'Bridgetown', -59.6105, 13.0935);
INSERT INTO public.countries VALUES ('Belarus', 'BY', 'BLR', 2022, 9228071, 202990.0, '2024-12-16', 'Europe & Central Asia', 'Minsk', 27.5766, 53.9678);
INSERT INTO public.countries VALUES ('Belgium', 'BE', 'BEL', 2022, 11680210, 30494.0, '2024-12-16', 'Europe & Central Asia', 'Brussels', 4.36761, 50.8371);
INSERT INTO public.countries VALUES ('Belize', 'BZ', 'BLZ', 2022, 402733, 22810.0, '2024-12-16', 'Latin America & Caribbean', 'Belmopan', -88.7713, 17.2534);
INSERT INTO public.countries VALUES ('Benin', 'BJ', 'BEN', 2022, 13759501, 112760.0, '2024-12-16', 'Sub-Saharan Africa', 'Porto-Novo', 2.6323, 6.4779);
INSERT INTO public.countries VALUES ('Bermuda', 'BM', 'BMU', 2022, 64749, 54.0, '2024-12-16', 'North America', 'Hamilton', -64.706, 32.3293);
INSERT INTO public.countries VALUES ('Bhutan', 'BT', 'BTN', 2022, 780914, 38140.0, '2024-12-16', 'South Asia', 'Thimphu', 89.6177, 27.5768);
INSERT INTO public.countries VALUES ('Bolivia', 'BO', 'BOL', 2022, 12077154, 1083300.0, '2024-12-16', 'Latin America & Caribbean', 'La Paz', -66.1936, -13.9908);
INSERT INTO public.countries VALUES ('Bosnia and Herzegovina', 'BA', 'BIH', 2022, 3204802, 51200.0, '2024-12-16', 'Europe & Central Asia', 'Sarajevo', 18.4214, 43.8607);
INSERT INTO public.countries VALUES ('Botswana', 'BW', 'BWA', 2022, 2439892, 566730.0, '2024-12-16', 'Sub-Saharan Africa', 'Gaborone', 25.9201, -24.6544);
INSERT INTO public.countries VALUES ('Brazil', 'BR', 'BRA', 2022, 210306415, 8358140.0, '2024-12-16', 'Latin America & Caribbean', 'Brasilia', -47.9292, -15.7801);
INSERT INTO public.countries VALUES ('British Virgin Islands', 'VG', 'VGB', 2022, 38319, 150.0, '2024-12-16', 'Latin America & Caribbean', 'Road Town', -64.623055, 18.431389);
INSERT INTO public.countries VALUES ('Brunei Darussalam', 'BN', 'BRN', 2022, 455370, 5270.0, '2024-12-16', 'East Asia & Pacific', 'Bandar Seri Begawan', 114.946, 4.94199);
INSERT INTO public.countries VALUES ('Bulgaria', 'BG', 'BGR', 2022, 6643324, 108560.0, '2024-12-16', 'Europe & Central Asia', 'Sofia', 23.3238, 42.7105);
INSERT INTO public.countries VALUES ('Burkina Faso', 'BF', 'BFA', 2022, 22509038, 273600.0, '2024-12-16', 'Sub-Saharan Africa', 'Ouagadougou', -1.53395, 12.3605);
INSERT INTO public.countries VALUES ('Burundi', 'BI', 'BDI', 2022, 13321097, 25680.0, '2024-12-16', 'Sub-Saharan Africa', 'Bujumbura', 29.3639, -3.3784);
INSERT INTO public.countries VALUES ('Cabo Verde', 'CV', 'CPV', 2022, 519741, 4030.0, '2024-12-16', 'Sub-Saharan Africa', 'Praia', -23.5087, 14.9218);
INSERT INTO public.countries VALUES ('Cambodia', 'KH', 'KHM', 2022, 17201724, 176520.0, '2024-12-16', 'East Asia & Pacific', 'Phnom Penh', 104.874, 11.5556);
INSERT INTO public.countries VALUES ('Cameroon', 'CM', 'CMR', 2022, 27632771, 472710.0, '2024-12-16', 'Sub-Saharan Africa', 'Yaounde', 11.5174, 3.8721);
INSERT INTO public.countries VALUES ('Canada', 'CA', 'CAN', 2022, 38939056, 8788700.0, '2024-12-16', 'North America', 'Ottawa', -75.6919, 45.4215);
INSERT INTO public.countries VALUES ('Cayman Islands', 'KY', 'CYM', 2022, 71591, 240.0, '2024-12-16', 'Latin America & Caribbean', 'George Town', -81.3857, 19.3022);
INSERT INTO public.countries VALUES ('Central African Republic', 'CF', 'CAF', 2022, 5098039, 622980.0, '2024-12-16', 'Sub-Saharan Africa', 'Bangui', 21.6407, 5.63056);
INSERT INTO public.countries VALUES ('Chad', 'TD', 'TCD', 2022, 18455316, 1259200.0, '2024-12-16', 'Sub-Saharan Africa', 'N''Djamena', 15.0445, 12.1048);
INSERT INTO public.countries VALUES ('Channel Islands', 'JG', 'CHI', 2022, 167215, NULL, '2024-12-16', 'Europe & Central Asia', NULL, NULL, NULL);
INSERT INTO public.countries VALUES ('Chile', 'CL', 'CHL', 2022, 19553036, 743532.0, '2024-12-16', 'Latin America & Caribbean', 'Santiago', -70.6475, -33.475);
INSERT INTO public.countries VALUES ('China', 'CN', 'CHN', 2022, 1412175000, 9388210.0, '2024-12-16', 'East Asia & Pacific', 'Beijing', 116.286, 40.0495);
INSERT INTO public.countries VALUES ('Colombia', 'CO', 'COL', 2022, 51737944, 1109500.0, '2024-12-16', 'Latin America & Caribbean', 'Bogota', -74.082, 4.60987);
INSERT INTO public.countries VALUES ('Comoros', 'KM', 'COM', 2022, 834188, 1861.0, '2024-12-16', 'Sub-Saharan Africa', 'Moroni', 43.2418, -11.6986);
INSERT INTO public.countries VALUES ('Congo, Dem. Rep.', 'CD', 'COD', 2022, 102396968, 2267050.0, '2024-12-16', 'Sub-Saharan Africa', 'Kinshasa', 15.3222, -4.325);
INSERT INTO public.countries VALUES ('Congo, Rep.', 'CG', 'COG', 2022, 6035104, 341500.0, '2024-12-16', 'Sub-Saharan Africa', 'Brazzaville', 15.2662, -4.2767);
INSERT INTO public.countries VALUES ('Costa Rica', 'CR', 'CRI', 2022, 5081765, 51060.0, '2024-12-16', 'Latin America & Caribbean', 'San Jose', -84.0089, 9.63701);
INSERT INTO public.countries VALUES ('Cote d''Ivoire', 'CI', 'CIV', 2022, 30395002, 318000.0, '2024-12-16', 'Sub-Saharan Africa', 'Yamoussoukro', -4.0305, 5.332);
INSERT INTO public.countries VALUES ('Croatia', 'HR', 'HRV', 2022, 3855641, 55960.0, '2024-12-16', 'Europe & Central Asia', 'Zagreb', 15.9614, 45.8069);
INSERT INTO public.countries VALUES ('Cuba', 'CU', 'CUB', 2022, 11059820, 103800.0, '2024-12-16', 'Latin America & Caribbean', 'Havana', -82.3667, 23.1333);
INSERT INTO public.countries VALUES ('Curacao', 'CW', 'CUW', 2022, 149996, 444.0, '2024-12-16', 'Latin America & Caribbean', 'Willemstad', NULL, NULL);
INSERT INTO public.countries VALUES ('Cyprus', 'CY', 'CYP', 2022, 1331370, 9240.0, '2024-12-16', 'Europe & Central Asia', 'Nicosia', 33.3736, 35.1676);
INSERT INTO public.countries VALUES ('Denmark', 'DK', 'DNK', 2022, 5903037, 40000.0, '2024-12-16', 'Europe & Central Asia', 'Copenhagen', 12.5681, 55.6763);
INSERT INTO public.countries VALUES ('Djibouti', 'DJ', 'DJI', 2022, 1137096, 23180.0, '2024-12-16', 'Middle East & North Africa', 'Djibouti', 43.1425, 11.5806);
INSERT INTO public.countries VALUES ('Dominica', 'DM', 'DMA', 2022, 66826, 750.0, '2024-12-16', 'Latin America & Caribbean', 'Roseau', -61.39, 15.2976);
INSERT INTO public.countries VALUES ('Dominican Republic', 'DO', 'DOM', 2022, 11230734, 48198.02, '2024-12-16', 'Latin America & Caribbean', 'Santo Domingo', -69.8908, 18.479);
INSERT INTO public.countries VALUES ('Ecuador', 'EC', 'ECU', 2022, 17823897, 248360.0, '2024-12-16', 'Latin America & Caribbean', 'Quito', -78.5243, -0.229498);
INSERT INTO public.countries VALUES ('Egypt, Arab Rep.', 'EG', 'EGY', 2022, 112618250, 995450.0, '2024-12-16', 'Middle East & North Africa', 'Cairo', 31.2461, 30.0982);
INSERT INTO public.countries VALUES ('El Salvador', 'SV', 'SLV', 2022, 6280319, 20720.0, '2024-12-16', 'Latin America & Caribbean', 'San Salvador', -89.2073, 13.7034);
INSERT INTO public.countries VALUES ('Equatorial Guinea', 'GQ', 'GNQ', 2022, 1803545, 28050.0, '2024-12-16', 'Sub-Saharan Africa', 'Malabo', 8.7741, 3.7523);
INSERT INTO public.countries VALUES ('Eritrea', 'ER', 'ERI', 2022, 3409447, 121040.829, '2024-12-16', 'Sub-Saharan Africa', 'Asmara', 38.9183, 15.3315);
INSERT INTO public.countries VALUES ('Estonia', 'EE', 'EST', 2022, 1348840, 42730.0, '2024-12-16', 'Europe & Central Asia', 'Tallinn', 24.7586, 59.4392);
INSERT INTO public.countries VALUES ('Eswatini', 'SZ', 'SWZ', 2022, 1218917, 17200.0, '2024-12-16', 'Sub-Saharan Africa', 'Mbabane', 31.4659, -26.5225);
INSERT INTO public.countries VALUES ('Ethiopia', 'ET', 'ETH', 2022, 125384287, 1128571.4, '2024-12-16', 'Sub-Saharan Africa', 'Addis Ababa', 38.7468, 9.02274);
INSERT INTO public.countries VALUES ('Faroe Islands', 'FO', 'FRO', 2022, 53952, 1370.0, '2024-12-16', 'Europe & Central Asia', 'Torshavn', -6.91181, 61.8926);
INSERT INTO public.countries VALUES ('Fiji', 'FJ', 'FJI', 2022, 919422, 18270.0, '2024-12-16', 'East Asia & Pacific', 'Suva', 178.399, -18.1149);
INSERT INTO public.countries VALUES ('Finland', 'FI', 'FIN', 2022, 5556106, 303947.7, '2024-12-16', 'Europe & Central Asia', 'Helsinki', 24.9525, 60.1608);
INSERT INTO public.countries VALUES ('France', 'FR', 'FRA', 2022, 68065015, 547557.0, '2024-12-16', 'Europe & Central Asia', 'Paris', 2.35097, 48.8566);
INSERT INTO public.countries VALUES ('French Polynesia', 'PF', 'PYF', 2022, 280378, 3471.0, '2024-12-16', 'East Asia & Pacific', 'Papeete', -149.57, -17.535);
INSERT INTO public.countries VALUES ('Gabon', 'GA', 'GAB', 2022, 2430747, 257670.0, '2024-12-16', 'Sub-Saharan Africa', 'Libreville', 9.45162, 0.38832);
INSERT INTO public.countries VALUES ('Gambia, The', 'GM', 'GMB', 2022, 2636470, 10120.0, '2024-12-16', 'Sub-Saharan Africa', 'Banjul', -16.5885, 13.4495);
INSERT INTO public.countries VALUES ('Georgia', 'GE', 'GEO', 2022, 3712502, 69490.0, '2024-12-16', 'Europe & Central Asia', 'Tbilisi', 44.793, 41.71);
INSERT INTO public.countries VALUES ('Germany', 'DE', 'DEU', 2022, 83797985, 349360.0, '2024-12-16', 'Europe & Central Asia', 'Berlin', 13.4115, 52.5235);
INSERT INTO public.countries VALUES ('Ghana', 'GH', 'GHA', 2022, 33149152, 227533.0, '2024-12-16', 'Sub-Saharan Africa', 'Accra', -0.20795, 5.57045);
INSERT INTO public.countries VALUES ('Gibraltar', 'GI', 'GIB', 2022, 37609, NULL, '2024-12-16', 'Europe & Central Asia', NULL, NULL, NULL);
INSERT INTO public.countries VALUES ('Greece', 'GR', 'GRC', 2022, 10436882, 128900.0, '2024-12-16', 'Europe & Central Asia', 'Athens', 23.7166, 37.9792);
INSERT INTO public.countries VALUES ('Greenland', 'GL', 'GRL', 2022, 56661, 410450.0, '2024-12-16', 'Europe & Central Asia', 'Nuuk', -51.7214, 64.1836);
INSERT INTO public.countries VALUES ('Grenada', 'GD', 'GRD', 2022, 116913, 340.0, '2024-12-16', 'Latin America & Caribbean', 'Saint George''s', -61.7449, 12.0653);
INSERT INTO public.countries VALUES ('Guam', 'GU', 'GUM', 2022, 165180, 540.0, '2024-12-16', 'East Asia & Pacific', 'Agana', 144.794, 13.4443);
INSERT INTO public.countries VALUES ('Guatemala', 'GT', 'GTM', 2022, 17847877, 107160.0, '2024-12-16', 'Latin America & Caribbean', 'Guatemala City', -90.5328, 14.6248);
INSERT INTO public.countries VALUES ('Guinea', 'GN', 'GIN', 2022, 14055137, 245720.0, '2024-12-16', 'Sub-Saharan Africa', 'Conakry', -13.7, 9.51667);
INSERT INTO public.countries VALUES ('Guinea-Bissau', 'GW', 'GNB', 2022, 2105529, 28120.0, '2024-12-16', 'Sub-Saharan Africa', 'Bissau', -15.1804, 11.8037);
INSERT INTO public.countries VALUES ('Guyana', 'GY', 'GUY', 2022, 821637, 196850.0, '2024-12-16', 'Latin America & Caribbean', 'Georgetown', -58.1548, 6.80461);
INSERT INTO public.countries VALUES ('Haiti', 'HT', 'HTI', 2022, 11503606, 27560.0, '2024-12-16', 'Latin America & Caribbean', 'Port-au-Prince', -72.3288, 18.5392);
INSERT INTO public.countries VALUES ('Honduras', 'HN', 'HND', 2022, 10463872, 111890.0, '2024-12-16', 'Latin America & Caribbean', 'Tegucigalpa', -87.4667, 15.1333);
INSERT INTO public.countries VALUES ('Hong Kong SAR, China', 'HK', 'HKG', 2022, 7346100, NULL, '2024-12-16', 'East Asia & Pacific', NULL, 114.109, 22.3964);
INSERT INTO public.countries VALUES ('Hungary', 'HU', 'HUN', 2022, 9644377, 91260.0, '2024-12-16', 'Europe & Central Asia', 'Budapest', 19.0408, 47.4984);
INSERT INTO public.countries VALUES ('Iceland', 'IS', 'ISL', 2022, 382003, 100830.0, '2024-12-16', 'Europe & Central Asia', 'Reykjavik', -21.8952, 64.1353);
INSERT INTO public.countries VALUES ('India', 'IN', 'IND', 2022, 1425423212, 2973190.0, '2024-12-16', 'South Asia', 'New Delhi', 77.225, 28.6353);
INSERT INTO public.countries VALUES ('Indonesia', 'ID', 'IDN', 2022, 278830529, 1892555.47, '2024-12-16', 'East Asia & Pacific', 'Jakarta', 106.83, -6.19752);
INSERT INTO public.countries VALUES ('Iran, Islamic Rep.', 'IR', 'IRN', 2022, 89524246, 1622500.0, '2024-12-16', 'Middle East & North Africa', 'Tehran', 51.4447, 35.6878);
INSERT INTO public.countries VALUES ('Iraq', 'IQ', 'IRQ', 2022, 44070551, 434128.0, '2024-12-16', 'Middle East & North Africa', 'Baghdad', 44.394, 33.3302);
INSERT INTO public.countries VALUES ('Ireland', 'IE', 'IRL', 2022, 5165700, 68890.0, '2024-12-16', 'Europe & Central Asia', 'Dublin', -6.26749, 53.3441);
INSERT INTO public.countries VALUES ('Isle of Man', 'IM', 'IMN', 2022, 84132, 570.0, '2024-12-16', 'Europe & Central Asia', 'Douglas', -4.47928, 54.1509);
INSERT INTO public.countries VALUES ('Israel', 'IL', 'ISR', 2022, 9557500, NULL, '2024-12-16', 'Middle East & North Africa', NULL, 35.2035, 31.7717);
INSERT INTO public.countries VALUES ('Italy', 'IT', 'ITA', 2022, 59013667, 295720.0, '2024-12-16', 'Europe & Central Asia', 'Rome', 12.4823, 41.8955);
INSERT INTO public.countries VALUES ('Jamaica', 'JM', 'JAM', 2022, 2839144, 10830.0, '2024-12-16', 'Latin America & Caribbean', 'Kingston', -76.792, 17.9927);
INSERT INTO public.countries VALUES ('Japan', 'JP', 'JPN', 2022, 125124989, 364500.0, '2024-12-16', 'East Asia & Pacific', 'Tokyo', 139.77, 35.67);
INSERT INTO public.countries VALUES ('Jordan', 'JO', 'JOR', 2022, 11256263, 88794.0, '2024-12-16', 'Middle East & North Africa', 'Amman', 35.9263, 31.9497);
INSERT INTO public.countries VALUES ('Kazakhstan', 'KZ', 'KAZ', 2022, 20034609, 2699700.0, '2024-12-16', 'Europe & Central Asia', 'Astana', 71.4382, 51.1879);
INSERT INTO public.countries VALUES ('Kenya', 'KE', 'KEN', 2022, 54252461, 569140.0, '2024-12-16', 'Sub-Saharan Africa', 'Nairobi', 36.8126, -1.27975);
INSERT INTO public.countries VALUES ('Kiribati', 'KI', 'KIR', 2022, 130469, 810.0, '2024-12-16', 'East Asia & Pacific', 'Tarawa', 172.979, 1.32905);
INSERT INTO public.countries VALUES ('Korea, Dem. People''s Rep.', 'KP', 'PRK', 2022, 26328845, 120410.0, '2024-12-16', 'East Asia & Pacific', 'Pyongyang', 125.754, 39.0319);
INSERT INTO public.countries VALUES ('Korea, Rep.', 'KR', 'KOR', 2022, 51672569, 97600.0, '2024-12-16', 'East Asia & Pacific', 'Seoul', 126.957, 37.5323);
INSERT INTO public.countries VALUES ('Kosovo', 'XK', 'XKX', 2022, 1768096, NULL, '2024-12-16', 'Europe & Central Asia', 'Pristina', 20.926, 42.565);
INSERT INTO public.countries VALUES ('Kuwait', 'KW', 'KWT', 2022, 4589643, 17820.0, '2024-12-16', 'Middle East & North Africa', 'Kuwait City', 47.9824, 29.3721);
INSERT INTO public.countries VALUES ('Kyrgyz Republic', 'KG', 'KGZ', 2022, 6975220, 191800.0, '2024-12-16', 'Europe & Central Asia', 'Bishkek', 74.6057, 42.8851);
INSERT INTO public.countries VALUES ('Lao PDR', 'LA', 'LAO', 2022, 7559007, 230800.0, '2024-12-16', 'East Asia & Pacific', 'Vientiane', 102.177, 18.5826);
INSERT INTO public.countries VALUES ('Latvia', 'LV', 'LVA', 2022, 1879383, 62230.0, '2024-12-16', 'Europe & Central Asia', 'Riga', 24.1048, 56.9465);
INSERT INTO public.countries VALUES ('Lebanon', 'LB', 'LBN', 2022, 5744489, 10230.0, '2024-12-16', 'Middle East & North Africa', 'Beirut', 35.5134, 33.8872);
INSERT INTO public.countries VALUES ('Lesotho', 'LS', 'LSO', 2022, 2286110, 30360.0, '2024-12-16', 'Sub-Saharan Africa', 'Maseru', 27.7167, -29.5208);
INSERT INTO public.countries VALUES ('Liberia', 'LR', 'LBR', 2022, 5373294, 96320.0, '2024-12-16', 'Sub-Saharan Africa', 'Monrovia', -10.7957, 6.30039);
INSERT INTO public.countries VALUES ('Libya', 'LY', 'LBY', 2022, 7223805, 1759540.0, '2024-12-16', 'Middle East & North Africa', 'Tripoli', 13.1072, 32.8578);
INSERT INTO public.countries VALUES ('Liechtenstein', 'LI', 'LIE', 2022, 39493, 160.0, '2024-12-16', 'Europe & Central Asia', 'Vaduz', 9.52148, 47.1411);
INSERT INTO public.countries VALUES ('Lithuania', 'LT', 'LTU', 2022, 2831639, 62604.0, '2024-12-16', 'Europe & Central Asia', 'Vilnius', 25.2799, 54.6896);
INSERT INTO public.countries VALUES ('Luxembourg', 'LU', 'LUX', 2022, 653103, 2574.46, '2024-12-16', 'Europe & Central Asia', 'Luxembourg', 6.1296, 49.61);
INSERT INTO public.countries VALUES ('Macao SAR, China', 'MO', 'MAC', 2022, 677300, NULL, '2024-12-16', 'East Asia & Pacific', NULL, 113.55, 22.1667);
INSERT INTO public.countries VALUES ('Madagascar', 'MG', 'MDG', 2022, 30437261, 581800.0, '2024-12-16', 'Sub-Saharan Africa', 'Antananarivo', 45.7167, -20.4667);
INSERT INTO public.countries VALUES ('Malawi', 'MW', 'MWI', 2022, 20568728, 94280.0, '2024-12-16', 'Sub-Saharan Africa', 'Lilongwe', 33.7703, -13.9899);
INSERT INTO public.countries VALUES ('Malaysia', 'MY', 'MYS', 2022, 34695493, 328550.0, '2024-12-16', 'East Asia & Pacific', 'Kuala Lumpur', 101.684, 3.12433);
INSERT INTO public.countries VALUES ('Maldives', 'MV', 'MDV', 2022, 524106, 300.0, '2024-12-16', 'South Asia', 'Male', 73.5109, 4.1742);
INSERT INTO public.countries VALUES ('Mali', 'ML', 'MLI', 2022, 23072640, 1220190.0, '2024-12-16', 'Sub-Saharan Africa', 'Bamako', -7.50034, 13.5667);
INSERT INTO public.countries VALUES ('Malta', 'MT', 'MLT', 2022, 531511, 320.0, '2024-12-16', 'Middle East & North Africa', 'Valletta', 14.5189, 35.9042);
INSERT INTO public.countries VALUES ('Marshall Islands', 'MH', 'MHL', 2022, 40077, 180.0, '2024-12-16', 'East Asia & Pacific', 'Majuro', 171.135, 7.11046);
INSERT INTO public.countries VALUES ('Mauritania', 'MR', 'MRT', 2022, 4875637, 1030700.0, '2024-12-16', 'Sub-Saharan Africa', 'Nouakchott', -15.9824, 18.2367);
INSERT INTO public.countries VALUES ('Mauritius', 'MU', 'MUS', 2022, 1262523, 1997.0, '2024-12-16', 'Sub-Saharan Africa', 'Port Louis', 57.4977, -20.1605);
INSERT INTO public.countries VALUES ('Mexico', 'MX', 'MEX', 2022, 128613117, 1943950.0, '2024-12-16', 'Latin America & Caribbean', 'Mexico City', -99.1276, 19.427);
INSERT INTO public.countries VALUES ('Micronesia, Fed. Sts.', 'FM', 'FSM', 2022, 112114, 700.0, '2024-12-16', 'East Asia & Pacific', 'Palikir', 158.185, 6.91771);
INSERT INTO public.countries VALUES ('Moldova', 'MD', 'MDA', 2022, 2528654, 32890.0, '2024-12-16', 'Europe & Central Asia', 'Chisinau', 28.8497, 47.0167);
INSERT INTO public.countries VALUES ('Monaco', 'MC', 'MCO', 2022, 38931, 2.084, '2024-12-16', 'Europe & Central Asia', 'Monaco', 7.41891, 43.7325);
INSERT INTO public.countries VALUES ('Mongolia', 'MN', 'MNG', 2022, 3433748, 1557506.789, '2024-12-16', 'East Asia & Pacific', 'Ulaanbaatar', 106.937, 47.9129);
INSERT INTO public.countries VALUES ('Montenegro', 'ME', 'MNE', 2022, 617213, 13450.0, '2024-12-16', 'Europe & Central Asia', 'Podgorica', 19.2595, 42.4602);
INSERT INTO public.countries VALUES ('Morocco', 'MA', 'MAR', 2022, 37329064, 446300.0, '2024-12-16', 'Middle East & North Africa', 'Rabat', -6.8704, 33.9905);
INSERT INTO public.countries VALUES ('Mozambique', 'MZ', 'MOZ', 2022, 32656246, 786380.0, '2024-12-16', 'Sub-Saharan Africa', 'Maputo', 32.5713, -25.9664);
INSERT INTO public.countries VALUES ('Myanmar', 'MM', 'MMR', 2022, 53756787, 652670.0, '2024-12-16', 'East Asia & Pacific', 'Naypyidaw', 95.9562, 21.914);
INSERT INTO public.countries VALUES ('Namibia', 'NA', 'NAM', 2022, 2889662, 823290.0, '2024-12-16', 'Sub-Saharan Africa', 'Windhoek', 17.0931, -22.5648);
INSERT INTO public.countries VALUES ('Nauru', 'NR', 'NRU', 2022, 11801, 20.0, '2024-12-16', 'East Asia & Pacific', 'Yaren District', 166.92087, -0.5477);
INSERT INTO public.countries VALUES ('Nepal', 'NP', 'NPL', 2022, 29715436, 143350.0, '2024-12-16', 'South Asia', 'Kathmandu', 85.3157, 27.6939);
INSERT INTO public.countries VALUES ('Netherlands', 'NL', 'NLD', 2022, 17700982, 33670.0, '2024-12-16', 'Europe & Central Asia', 'Amsterdam', 4.89095, 52.3738);
INSERT INTO public.countries VALUES ('New Caledonia', 'NC', 'NCL', 2022, 287123, 18280.0, '2024-12-16', 'East Asia & Pacific', 'Noum''ea', 166.464, -22.2677);
INSERT INTO public.countries VALUES ('New Zealand', 'NZ', 'NZL', 2022, 5117200, 263310.0, '2024-12-16', 'East Asia & Pacific', 'Wellington', 174.776, -41.2865);
INSERT INTO public.countries VALUES ('Nicaragua', 'NI', 'NIC', 2022, 6730654, 120340.0, '2024-12-16', 'Latin America & Caribbean', 'Managua', -86.2734, 12.1475);
INSERT INTO public.countries VALUES ('Niger', 'NE', 'NER', 2022, 25311973, 1266700.0, '2024-12-16', 'Sub-Saharan Africa', 'Niamey', 2.1073, 13.514);
INSERT INTO public.countries VALUES ('Nigeria', 'NG', 'NGA', 2022, 223150896, 910770.0, '2024-12-16', 'Sub-Saharan Africa', 'Abuja', 7.48906, 9.05804);
INSERT INTO public.countries VALUES ('North Macedonia', 'MK', 'MKD', 2022, 1831712, 25220.0, '2024-12-16', 'Europe & Central Asia', 'Skopje', 21.4361, 42.0024);
INSERT INTO public.countries VALUES ('Northern Mariana Islands', 'MP', 'MNP', 2022, 46078, 460.0, '2024-12-16', 'East Asia & Pacific', 'Saipan', 145.765, 15.1935);
INSERT INTO public.countries VALUES ('Norway', 'NO', 'NOR', 2022, 5457127, 364270.0, '2024-12-16', 'Europe & Central Asia', 'Oslo', 10.7387, 59.9138);
INSERT INTO public.countries VALUES ('Oman', 'OM', 'OMN', 2022, 4730226, 309500.0, '2024-12-16', 'Middle East & North Africa', 'Muscat', 58.5874, 23.6105);
INSERT INTO public.countries VALUES ('Pakistan', 'PK', 'PAK', 2022, 243700667, 770880.0, '2024-12-16', 'South Asia', 'Islamabad', 72.8, 30.5167);
INSERT INTO public.countries VALUES ('Palau', 'PW', 'PLW', 2022, 17759, 460.0, '2024-12-16', 'East Asia & Pacific', 'Koror', 134.479, 7.34194);
INSERT INTO public.countries VALUES ('Panama', 'PA', 'PAN', 2022, 4400773, 74180.0, '2024-12-16', 'Latin America & Caribbean', 'Panama City', -79.5188, 8.99427);
INSERT INTO public.countries VALUES ('Papua New Guinea', 'PG', 'PNG', 2022, 10203169, 452860.0, '2024-12-16', 'East Asia & Pacific', 'Port Moresby', 147.194, -9.47357);
INSERT INTO public.countries VALUES ('Paraguay', 'PY', 'PRY', 2022, 6760464, 396012.042, '2024-12-16', 'Latin America & Caribbean', 'Asuncion', -57.6362, -25.3005);
INSERT INTO public.countries VALUES ('Peru', 'PE', 'PER', 2022, 33475438, 1280000.0, '2024-12-16', 'Latin America & Caribbean', 'Lima', -77.0465, -12.0931);
INSERT INTO public.countries VALUES ('Philippines', 'PH', 'PHL', 2022, 113964338, 298170.0, '2024-12-16', 'East Asia & Pacific', 'Manila', 121.035, 14.5515);
INSERT INTO public.countries VALUES ('Poland', 'PL', 'POL', 2022, 36821749, 306090.0, '2024-12-16', 'Europe & Central Asia', 'Warsaw', 21.02, 52.26);
INSERT INTO public.countries VALUES ('Portugal', 'PT', 'PRT', 2022, 10434332, 91605.6, '2024-12-16', 'Europe & Central Asia', 'Lisbon', -9.13552, 38.7072);
INSERT INTO public.countries VALUES ('Puerto Rico', 'PR', 'PRI', 2022, 3220113, 8870.0, '2024-12-16', 'Latin America & Caribbean', 'San Juan', -66, 18.23);
INSERT INTO public.countries VALUES ('Qatar', 'QA', 'QAT', 2022, 2657333, 11490.0, '2024-12-16', 'Middle East & North Africa', 'Doha', 51.5082, 25.2948);
INSERT INTO public.countries VALUES ('Romania', 'RO', 'ROU', 2022, 19048502, 230080.0, '2024-12-16', 'Europe & Central Asia', 'Bucharest', 26.0979, 44.4479);
INSERT INTO public.countries VALUES ('Russian Federation', 'RU', 'RUS', 2022, 144236933, 16376870, '2024-12-16', 'Europe & Central Asia', 'Moscow', 37.6176, 55.7558);
INSERT INTO public.countries VALUES ('Rwanda', 'RW', 'RWA', 2022, 13651030, 24670.0, '2024-12-16', 'Sub-Saharan Africa', 'Kigali', 30.0587, -1.95325);
INSERT INTO public.countries VALUES ('Samoa', 'WS', 'WSM', 2022, 215261, 2780.0, '2024-12-16', 'East Asia & Pacific', 'Apia', -171.752, -13.8314);
INSERT INTO public.countries VALUES ('San Marino', 'SM', 'SMR', 2022, 33755, 60.0, '2024-12-16', 'Europe & Central Asia', 'San Marino', 12.4486, 43.9322);
INSERT INTO public.countries VALUES ('Sao Tome and Principe', 'ST', 'STP', 2022, 226305, 960.0, '2024-12-16', 'Sub-Saharan Africa', 'Sao Tome', 6.6071, 0.20618);
INSERT INTO public.countries VALUES ('Saudi Arabia', 'SA', 'SAU', 2022, 32175224, 2149690.0, '2024-12-16', 'Middle East & North Africa', 'Riyadh', 46.6977, 24.6748);
INSERT INTO public.countries VALUES ('Senegal', 'SN', 'SEN', 2022, 17651103, 192530.0, '2024-12-16', 'Sub-Saharan Africa', 'Dakar', -17.4734, 14.7247);
INSERT INTO public.countries VALUES ('Serbia', 'RS', 'SRB', 2022, 6664449, 84090.0, '2024-12-16', 'Europe & Central Asia', 'Belgrade', 20.4656, 44.8024);
INSERT INTO public.countries VALUES ('Seychelles', 'SC', 'SYC', 2022, 119878, 460.0, '2024-12-16', 'Sub-Saharan Africa', 'Victoria', 55.4466, -4.6309);
INSERT INTO public.countries VALUES ('Sierra Leone', 'SL', 'SLE', 2022, 8276807, 72180.0, '2024-12-16', 'Sub-Saharan Africa', 'Freetown', -13.2134, 8.4821);
INSERT INTO public.countries VALUES ('Singapore', 'SG', 'SGP', 2022, 5637022, 718.0, '2024-12-16', 'East Asia & Pacific', 'Singapore', 103.85, 1.28941);
INSERT INTO public.countries VALUES ('Sint Maarten (Dutch part)', 'SX', 'SXM', 2022, 42139, 34.0, '2024-12-16', 'Latin America & Caribbean', 'Philipsburg', NULL, NULL);
INSERT INTO public.countries VALUES ('Slovak Republic', 'SK', 'SVK', 2022, 5431752, 48080.0, '2024-12-16', 'Europe & Central Asia', 'Bratislava', 17.1073, 48.1484);
INSERT INTO public.countries VALUES ('Slovenia', 'SI', 'SVN', 2022, 2112076, 20136.4, '2024-12-16', 'Europe & Central Asia', 'Ljubljana', 14.5044, 46.0546);
INSERT INTO public.countries VALUES ('Solomon Islands', 'SB', 'SLB', 2022, 781066, 27990.0, '2024-12-16', 'East Asia & Pacific', 'Honiara', 159.949, -9.42676);
INSERT INTO public.countries VALUES ('Somalia', 'SO', 'SOM', 2022, 17801897, 627340.0, '2024-12-16', 'Sub-Saharan Africa', 'Mogadishu', 45.3254, 2.07515);
INSERT INTO public.countries VALUES ('South Africa', 'ZA', 'ZAF', 2022, 62378410, 1213090.0, '2024-12-16', 'Sub-Saharan Africa', 'Pretoria', 28.1871, -25.746);
INSERT INTO public.countries VALUES ('South Sudan', 'SS', 'SSD', 2022, 11021177, 631930.0, '2024-12-16', 'Sub-Saharan Africa', 'Juba', 31.6, 4.85);
INSERT INTO public.countries VALUES ('Spain', 'ES', 'ESP', 2022, 47759127, 499713.681, '2024-12-16', 'Europe & Central Asia', 'Madrid', -3.70327, 40.4167);
INSERT INTO public.countries VALUES ('Sri Lanka', 'LK', 'LKA', 2022, 22181000, 61860.0, '2024-12-16', 'South Asia', 'Colombo', 79.8528, 6.92148);
INSERT INTO public.countries VALUES ('St. Kitts and Nevis', 'KN', 'KNA', 2022, 46709, 260.0, '2024-12-16', 'Latin America & Caribbean', 'Basseterre', -62.7309, 17.3);
INSERT INTO public.countries VALUES ('St. Lucia', 'LC', 'LCA', 2022, 178781, 610.0, '2024-12-16', 'Latin America & Caribbean', 'Castries', -60.9832, 14);
INSERT INTO public.countries VALUES ('St. Martin (French part)', 'MF', 'MAF', 2022, 28870, 50.0, '2024-12-16', 'Latin America & Caribbean', 'Marigot', NULL, NULL);
INSERT INTO public.countries VALUES ('St. Vincent and the Grenadines', 'VC', 'VCT', 2022, 102046, 390.0, '2024-12-16', 'Latin America & Caribbean', 'Kingstown', -61.2653, 13.2035);
INSERT INTO public.countries VALUES ('Sudan', 'SD', 'SDN', 2022, 49383346, 1868000.0, '2024-12-16', 'Sub-Saharan Africa', 'Khartoum', 32.5363, 15.5932);
INSERT INTO public.countries VALUES ('Suriname', 'SR', 'SUR', 2022, 623164, 160507.61, '2024-12-16', 'Latin America & Caribbean', 'Paramaribo', -55.1679, 5.8232);
INSERT INTO public.countries VALUES ('Sweden', 'SE', 'SWE', 2022, 10486941, 407280.0, '2024-12-16', 'Europe & Central Asia', 'Stockholm', 18.0645, 59.3327);
INSERT INTO public.countries VALUES ('Switzerland', 'CH', 'CHE', 2022, 8777088, 39509.63, '2024-12-16', 'Europe & Central Asia', 'Bern', 7.44821, 46.948);
INSERT INTO public.countries VALUES ('Syrian Arab Republic', 'SY', 'SYR', 2022, 22462173, 185179.709, '2024-12-16', 'Middle East & North Africa', 'Damascus', 36.3119, 33.5146);
INSERT INTO public.countries VALUES ('Tajikistan', 'TJ', 'TJK', 2022, 10182222, 138790.0, '2024-12-16', 'Europe & Central Asia', 'Dushanbe', 68.7864, 38.5878);
INSERT INTO public.countries VALUES ('Tanzania', 'TZ', 'TZA', 2022, 64711821, 885800.0, '2024-12-16', 'Sub-Saharan Africa', 'Dodoma', 35.7382, -6.17486);
INSERT INTO public.countries VALUES ('Thailand', 'TH', 'THA', 2022, 71735329, 510890.0, '2024-12-16', 'East Asia & Pacific', 'Bangkok', 100.521, 13.7308);
INSERT INTO public.countries VALUES ('Timor-Leste', 'TL', 'TLS', 2022, 1369295, 14870.0, '2024-12-16', 'East Asia & Pacific', 'Dili', 125.567, -8.56667);
INSERT INTO public.countries VALUES ('Togo', 'TG', 'TGO', 2022, 9089738, 54390.0, '2024-12-16', 'Sub-Saharan Africa', 'Lome', 1.2255, 6.1228);
INSERT INTO public.countries VALUES ('Tonga', 'TO', 'TON', 2022, 105042, 720.0, '2024-12-16', 'East Asia & Pacific', 'Nuku''alofa', -175.216, -21.136);
INSERT INTO public.countries VALUES ('Trinidad and Tobago', 'TT', 'TTO', 2022, 1365805, 5130.0, '2024-12-16', 'Latin America & Caribbean', 'Port-of-Spain', -61.4789, 10.6596);
INSERT INTO public.countries VALUES ('Tunisia', 'TN', 'TUN', 2022, 12119334, 155360.0, '2024-12-16', 'Middle East & North Africa', 'Tunis', 10.21, 36.7899);
INSERT INTO public.countries VALUES ('Turkiye', 'TR', 'TUR', 2022, 84979913, 769630.0, '2024-12-16', 'Europe & Central Asia', 'Ankara', 32.3606, 39.7153);
INSERT INTO public.countries VALUES ('Turkmenistan', 'TM', 'TKM', 2022, 7230193, 469930.0, '2024-12-16', 'Europe & Central Asia', 'Ashgabat', 58.3794, 37.9509);
INSERT INTO public.countries VALUES ('Turks and Caicos Islands', 'TC', 'TCA', 2022, 45847, 950.0, '2024-12-16', 'Latin America & Caribbean', 'Grand Turk', -71.14139, 21.460278);
INSERT INTO public.countries VALUES ('Tuvalu', 'TV', 'TUV', 2022, 9992, 30.0, '2024-12-16', 'East Asia & Pacific', 'Funafuti', 179.08957, -8.631488);
INSERT INTO public.countries VALUES ('Uganda', 'UG', 'UGA', 2022, 47312719, 200520.0, '2024-12-16', 'Sub-Saharan Africa', 'Kampala', 32.5729, 0.314269);
INSERT INTO public.countries VALUES ('Ukraine', 'UA', 'UKR', 2022, 41048766, 579400.0, '2024-12-16', 'Europe & Central Asia', 'Kiev', 30.5038, 50.4536);
INSERT INTO public.countries VALUES ('United Arab Emirates', 'AE', 'ARE', 2022, 10074977, 71020.0, '2024-12-16', 'Middle East & North Africa', 'Abu Dhabi', 54.3705, 24.4764);
INSERT INTO public.countries VALUES ('United Kingdom', 'GB', 'GBR', 2022, 67791000, 241930.0, '2024-12-16', 'Europe & Central Asia', 'London', -0.126236, 51.5002);
INSERT INTO public.countries VALUES ('United States', 'US', 'USA', 2022, 333271411, 9147420.0, '2024-12-16', 'North America', 'Washington D.C.', -77.032, 38.8895);
INSERT INTO public.countries VALUES ('Uruguay', 'UY', 'URY', 2022, 3390913, 175020.0, '2024-12-16', 'Latin America & Caribbean', 'Montevideo', -56.0675, -34.8941);
INSERT INTO public.countries VALUES ('Uzbekistan', 'UZ', 'UZB', 2022, 34938955, 440652.0, '2024-12-16', 'Europe & Central Asia', 'Tashkent', 69.269, 41.3052);
INSERT INTO public.countries VALUES ('Vanuatu', 'VU', 'VUT', 2022, 313046, 12190.0, '2024-12-16', 'East Asia & Pacific', 'Port-Vila', 168.321, -17.7404);
INSERT INTO public.countries VALUES ('Venezuela, RB', 'VE', 'VEN', 2022, 28213017, 882050.0, '2024-12-16', 'Latin America & Caribbean', 'Caracas', -69.8371, 9.08165);
INSERT INTO public.countries VALUES ('Virgin Islands (U.S.)', 'VI', 'VIR', 2022, 105413, 350.0, '2024-12-16', 'Latin America & Caribbean', 'Charlotte Amalie', -64.8963, 18.3358);
INSERT INTO public.countries VALUES ('West Bank and Gaza', 'PS', 'PSE', 2022, 5043612, NULL, '2024-12-16', 'Middle East & North Africa', NULL, NULL, NULL);
INSERT INTO public.countries VALUES ('Yemen, Rep.', 'YE', 'YEM', 2022, 38222876, 527970.0, '2024-12-16', 'Middle East & North Africa', 'Sana''a', 44.2075, 15.352);
INSERT INTO public.countries VALUES ('Zambia', 'ZM', 'ZMB', 2022, 20152938, 743390.0, '2024-12-16', 'Sub-Saharan Africa', 'Lusaka', 28.2937, -15.3982);
INSERT INTO public.countries VALUES ('Zimbabwe', 'ZW', 'ZWE', 2022, 16069056, 386850.0, '2024-12-16', 'Sub-Saharan Africa', 'Harare', 31.0672, -17.8312);


--
-- PostgreSQL database dump complete
--

