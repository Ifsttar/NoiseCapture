DROP TABLE IF EXISTS NOISECAPTURE_FREQ, NOISECAPTURE_POINT, NOISECAPTURE_TRACK, NOISECAPTURE_USER,
  NOISECAPTURE_TAG, NOISECAPTURE_TRACK_TAG, NOISECAPTURE_AREA, NOISECAPTURE_PROCESS_QUEUE,
  NOISECAPTURE_AREA_PROFILE, NOISECAPTURE_AREA_CLUSTER, NOISECAPTURE_PARTY, NOISECAPTURE_STATS_LAST_TRACKS, NOISECAPTURE_DUMP_TRACK_ENVELOPE;

 -- H2 Only
 CREATE DOMAIN IF NOT EXISTS TIMESTAMPTZ AS TIMESTAMP;

-- tables

-- Table: NOISECAPTURE_USER
CREATE TABLE NOISECAPTURE_USER (
    PK_USER serial  NOT NULL,
    USER_UUID char(36)  NOT NULL,
    PSEUDO text,
    DATE_CREATION date  NOT NULL,
    PROFILE varchar default '',
    CONSTRAINT NOISECAPTURE_USER_PK PRIMARY KEY (PK_USER)
);

COMMENT ON COLUMN NOISECAPTURE_USER.PROFILE IS 'User acoustic knowledge, one of NONE, NOVICE, EXPERT';

-- Table: NOISECAPTURE_PARTY
CREATE TABLE NOISECAPTURE_PARTY (
    PK_PARTY serial NOT NULL,
    THE_GEOM geometry NOT NULL,
    LAYER_NAME varchar UNIQUE NOT NULL,
    TITLE varchar NOT NULL,
    TAG varchar NOT NULL,
    DESCRIPTION varchar NOT NULL,
    START_TIME TIMESTAMPTZ,
    END_TIME TIMESTAMPTZ,
    FILTER_TIME boolean NOT NULL default false,
    FILTER_AREA boolean NOT NULL default false,
    CONSTRAINT NOISECAPTURE_PARTY_PK PRIMARY KEY (PK_PARTY)
);

COMMENT ON COLUMN NOISECAPTURE_PARTY.title IS 'Short NoiseParty title';
COMMENT ON COLUMN NOISECAPTURE_PARTY.description IS 'Long description of the NoiseParty';
COMMENT ON COLUMN NOISECAPTURE_PARTY.tag IS 'Tag typed by users';
COMMENT ON COLUMN NOISECAPTURE_PARTY.the_geom IS 'NoiseParty location';
COMMENT ON COLUMN NOISECAPTURE_PARTY.layer_name IS 'Layer name in leaflet url, must be unique';
COMMENT ON COLUMN NOISECAPTURE_PARTY.filter_time IS 'If enabled, reject track with time out of start_time end_time range';
COMMENT ON COLUMN NOISECAPTURE_PARTY.filter_area IS 'If enabled, reject track that does not intersects with the_geom';

-- NoiseCapture party data POSTGIS only
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (9, '0103000020E61000000100000005000000000000C02D05FFBF10000020176E4740000000C02D05FFBF080000E064B24740000000003FD9F1BF080000E064B24740000000003FD9F1BF10000020176E4740000000C02D05FFBF10000020176E4740', 'TEST44', 'Test noisecapture party', 'TEST44', 'NoiseCapture party for test purposes', '2018-03-17 01:00:00+00', '2030-03-25 23:59:59+00', true, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (11, '0103000020E61000000100000005000000000000E0735905C0000000603FD84740000000E0735905C010000020F5E2474080FFFF9F642E04C010000020F5E2474080FFFF9F642E04C0000000603FD84740000000E0735905C0000000603FD84740', 'PNRGM_Elven', 'FestNoise - Elven', 'PNRGM', 'Le Parc Naturel Régional du Golfe du Morbihan s''intéresse à l''effet du bruit sur la biodiversité. Nous vous proposons de venir arpenter les chemins d''Elven avec nous pour mesurer le bruit autour de vous ! Armé de votre smartphone Android et de l''application NoiseCapture, les mesures serviront à évaluer à quel point les espaces naturels sont impactés par la pollution sonore.', '2018-06-08 01:00:00+00', '2018-06-15 23:59:59+00', true, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (1, '01030000000100000005000000D3D9C9E028B902C08D7F9F71E1A04740D3D9C9E028B902C0A7AE7C96E7A1474029E8F692C6A802C0A7AE7C96E7A1474029E8F692C6A802C08D7F9F71E1A04740D3D9C9E028B902C08D7F9F71E1A04740', 'SNDIGITALWEEK', 'Digital Week 2017 Pornichet', 'SNDIGITALWEEK', '<p>La Ville de Pornichet s''associe à la Saint-Nazaire Digital Week le mercredi 20 septembre, et propose de nombreuses animations gratuites et ouvertes à tous dédiées au numérique à l''hippodrome.</p><p>Venez contribuer à la création d''une carte du bruit participative, en temps réel sur les territoires de la CARENE / CAP ATLANTIQUE grâce à l''utilisation d''une application smartphone : Noise Capture.</p>', NULL, NULL, false, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (6, '01030000000100000005000000CC2F839CCADA20C0F057421652A94540CC2F839CCADA20C027FE910E48AD4540978935F3BCC020C027FE910E48AD4540978935F3BCC020C0F057421652A94540CC2F839CCADA20C0F057421652A94540', 'UDC', 'Universidade da Coruña', 'UDC', 'This map belongs to the EDUCATION FOR SUSTAINABILITY project of Universidade da Coruña (http://www.udc.es; https://www.udc.es/sociedade/medio_ambiente/curso/) whose objective is to improve the training of the university community and citizenship in the basic concepts of environmental and social sustainability, and develop their capacity to act on those issues that are nowadays priorities (pollution, waste, climate change, resources, health...).', '2018-04-17 01:00:00+00', '2018-12-30 23:59:59+00', true, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (12, '010300000001000000050000006DE7FBA9F1521340DBF97E6ABC2C4A406DE7FBA9F1521340265305A392324A403480B74082E21340265305A392324A403480B74082E21340DBF97E6ABC2C4A406DE7FBA9F1521340DBF97E6ABC2C4A40', 'AMSOUNDS', 'Amsterdam Sounds: noise in the city', 'AMSOUNDS', 'How do you experience sound in your neighbourhood: the café around the corner, your neighbours or the nearby traffic? Or are you curious about the noise level you are exposed to during a festival? During this workshop we research noise and noise pollution, explore measuring strategies and use sensors to measure noise. Together we map sound in the city to then explore solutions and the possibilities of setting up a citizens’ measuring network.', '2018-06-20 01:00:00+00', '2018-09-20 23:59:59+00', true, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (13, '0103000020E6100000010000000500000080FFFF1FF06F07C00000004098D0474080FFFF1FF06F07C0100000E004D8474000000020F3D706C0100000E004D8474000000020F3D706C00000004098D0474080FFFF1FF06F07C00000004098D04740', 'PNRGM_Plougoumelen', 'NoiseParty - Plougoumelen', 'PNRGM', 'Le Parc Naturel Régional du Golfe du Morbihan s''intéresse à l''effet du bruit sur la biodiversité. Nous vous proposons de venir arpenter les chemins de Plougoumelen (56) avec nous pour mesurer le bruit autour de vous ! Armé de votre smartphone Android et de l''application NoiseCapture, les mesures serviront à évaluer à quel point les espaces naturels sont impactés par la pollution sonore.', '2018-07-18 01:00:00+00', '2018-08-31 23:59:59+00', true, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (3, '01030000000100000005000000000000803AFFF8BF000C66EBCD9A474000000000B3D9F8BF000C66EBCD9A474000000000B3D9F8BFD550B8E1189A4740000000803AFFF8BFD550B8E1189A4740000000803AFFF8BF000C66EBCD9A4740', 'FDS2017', 'Fête de la science 2017', 'FDS2017', '<p>Rendez-vous au Village des Sciences du 13 au 15 octobre 2017 à l''Ecole d''Architecture de Nantes. L''Amicale des doctorants de l''Ifsttar (Adin) vous fait découvrir des travaux de recherche innovants ! Profitez de l''événement avec le code #FDS2017 pour contribuez à la carte de bruit de la Région Nantaise. RDV au stand de l''Adin pour plus d''informations.</p>', '2017-10-12 01:00:00+00', '2017-10-16 01:00:00+00', true, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (2, '0103000000010000000500000045F0BF95EC1803406DC5FEB27B72484045F0BF95EC1803403411363CBD724840B0AC3429051D03403411363CBD724840B0AC3429051D03406DC5FEB27B72484045F0BF95EC1803406DC5FEB27B724840', 'ANQES2017', 'ANQES 2017', 'ANQES', '<p>À l''occasion des 8es Assises nationales de la qualité de l''environnement sonore, le CIDB vous propose de participer à une NoiseCapture Party. Pendant toute la durée de l’événement du 27 au 29 novembre, utilisez le code ANQES, mesurez les niveaux sonores durant vos trajets quotidiens et contribuez à l''élaboration de cartes de bruit. RDV au stand NoiseCapture pour plus d''informations.</p>', '2017-10-25 01:00:00+00', '2017-11-29 01:00:00+00', true, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (14, '01030000000100000005000000F88DAF3DB3041F40431CEBE2364A4840F88DAF3DB3041F406C09F9A0674B48406B65C22FF5131F406C09F9A0674B48406B65C22FF5131F40431CEBE2364A4840F88DAF3DB3041F40431CEBE2364A4840', 'FDSSTRAS2018', 'Stras'' NoiseCaptureParty ', 'FDSSTRAS', 'À l''occasion de la Fête de la Science du 12 au 14 octobre 2018, l''UMRAE vous propose de participer à une NoiseCapture Party. Mesurez l''environnement sonore autour du Village des Sciences de Strasbourg avec votre smartphone et contribuez à l''élaboration d''une carte de bruit en temps réel avec le code #FDSSTRAS. Rendez-vous au stand "Du son au bruit" pour plus d''informations. ', '2018-10-11 01:00:00+00', '2018-10-15 23:59:59+00', true, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (5, '0103000020E61000000100000005000000CD40FEC03BB310C0E8A9D53711EB4740CD40FEC03BB310C0FCAC62413EEE4740F20C3190DD9810C0FCAC62413EEE4740F20C3190DD9810C0E8A9D53711EB4740CD40FEC03BB310C0E8A9D53711EB4740', 'IMS2018', 'Immersion Sciences 2018', 'IMS2018', '"NoiseCapture": Capturez le bruit ! Aidez les scientifiques à cartographier l''environnement sonore.', NULL, NULL, false, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (20, '0103000000010000000500000048E17A14AEC71E407F6ABC749348484048E17A14AEC71E40D122DBF97E4A48405C8FC2F528DC1E40D122DBF97E4A48405C8FC2F528DC1E407F6ABC749348484048E17A14AEC71E407F6ABC7493484840', 'MSA2019', 'Maison pour la Science en Alsace', 'MSA', 'Dans le cadre du parcours de formation "A mon signal : son à volonté !", l''UMRAE propose de participer à une NoiseCapture Party. Les participants sont invités à mesurer l''environnement sonore autour du Laboratoire de Strasbourg du Cerema avec leur smartphone et à contribuer à l''élaboration d''une carte de bruit en temps réel avec le code #MSA.', '2019-01-09 01:00:00+00', '2019-01-11 23:59:59+00', true, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (17, '01030000000100000005000000D7A3703D0AD7FBBF8FC2F5285C8F4740D7A3703D0AD7FBBF0AD7A3703DAA4740E17A14AE47E1F6BF0AD7A3703DAA4740E17A14AE47E1F6BF8FC2F5285C8F4740D7A3703D0AD7FBBF8FC2F5285C8F4740', 'FDSNTS2018', 'NoiseCapture s''invite à la fête - Nantes', 'FDSNTS', 'Profitez de la Fête de la Science pour découvrir NoiseCapture et pour participer à l''élaboration participative de la carte de bruit de Nantes Métropole. Rendez-vous sur notre stand à l''Hôtel de la Région, le samedi 13 octobre de 10h à 18h et le dimanche 14 octobre de 14h à 18h.', '2018-10-11 01:00:00+00', '2018-10-15 23:59:59+00', true, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (15, '01030000000100000005000000BE9F1A2FDDE422400C022B8716594540BE9F1A2FDDE42240EE7C3F355E5A4540B6F3FDD478E92240EE7C3F355E5A4540B6F3FDD478E922400C022B8716594540BE9F1A2FDDE422400C022B8716594540', 'AGGLOBASTIA2018', 'Agglo Bastia Noise Party', 'AGGLOBASTIA', 'Avec la Communauté d''Agglomération de Bastia, le CNRS et l''Ifsttar, participez à un grand projet de recherche sur le bruit qui vous entoure. Pour ce faire, téléchargez l’application gratuite NoiseCapture sur votre smartphone Android et captez tous les bruits où que vous soyez sur l''emprise spatiale. Ils seront répertoriés dans une base de données qui permettra d’établir une cartographie du bruit à l''échelle mondiale. Et vous contribuerez aussi à la première étape d''un plan d''action de la CAB visant à mieux connaître et réduire les nuisances sonores.', '2018-10-04 01:00:00+00', '2018-12-31 23:59:59+00', true, false);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (10, '01030000000100000005000000A9DDC5FF958B2D40DDF7D5557C614440A9DDC5FF958B2D40ADBDDCF00F64444094B35E91C99E2D40ADBDDCF00F64444094B35E91C99E2D40DDF7D5557C614440A9DDC5FF958B2D40DDF7D5557C614440', 'UNISA', 'University of Salerno 2018', 'UNISA', 'NoiseCapture Party made by the University of Salerno', '2018-05-03 01:00:00+00', '2018-07-30 01:00:00+00', true, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (19, '01030000000100000005000000E9263108ACDC20C046B6F3FDD4A84540E9263108ACDC20C0713D0AD7A3B045405839B4C876BE20C0713D0AD7A3B045405839B4C876BE20C046B6F3FDD4A84540E9263108ACDC20C046B6F3FDD4A84540', 'UDC_2019', 'Contaminación acústica da Universidade da Coruña', 'UDC', 'Descuberta de contaminación acústica: En grupos faremos un mapeado acústico da UDC e da cidade da Coruña, localizando os lugares con contaminación acústica. Traballaremos en grupos e resolveremos ao final da xornada.', '2019-02-24 01:00:00+00', '2019-04-24 23:59:59+00', true, false);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (21, '01030000000100000005000000EE7C3F355EBAF9BFF0A7C64B37994740EE7C3F355EBAF9BFC3F5285C8FA247407F6ABC749318F8BFC3F5285C8FA247407F6ABC749318F8BFF0A7C64B37994740EE7C3F355EBAF9BFF0A7C64B37994740', 'GEO2019', 'Semaine "hors salle" L1 géographie et aménagement', 'GEO2019', 'L''université de Nantes organise chaque année, pour ses étudiants en L1 géographie et aménagement, une semaine « hors salle». Pendant cette semaine, les étudiants travaillent autour d''un projet défini par l''équipe pédagogique. Cette année, Claire Guiu et Christèle Allès (membres de cette équipe) s''associent à l''UMRAE pour aborder la thématique des environnements/paysages sonores.', '2019-03-11 01:00:00+00', '2019-03-16 23:59:59+00', true, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (18, '0103000000010000000500000033A6608DB33913404F081D7409DF464033A6608DB339134022A5D93C0EE54640575F5D15A875134022A5D93C0EE54640575F5D15A87513404F081D7409DF464033A6608DB33913404F081D7409DF4640', 'H2020Monica_Lyon2018', 'H2020 Monica Fête Des Lumières Party', 'H2020', 'Fête Des Lumières is an event that takes place in Lyon every nights between the 6th and 9th of December. For four nights, the keys of the city are given to different artists who light up buildings, street, squares and parks. All the city center becomes pedestrian and the sound environment changes with new sources like music or crowd noise.', '2018-12-06 01:00:00+00', '2018-12-10 01:00:00+00', true, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (22, '010300000001000000050000003333333333B310C05EBA490C02EB47403333333333B310C091ED7C3F35EE47407F6ABC74939810C091ED7C3F35EE47407F6ABC74939810C05EBA490C02EB47403333333333B310C05EBA490C02EB4740', 'IMS2019', 'Immersion Sciences 2019', 'IMS2019', '"NoiseCapture": Capturez le bruit ! Aidez les scientifiques à cartographier l''environnement sonore.', '2019-03-26 01:00:00+00', '2019-03-30 23:59:59+00', true, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (23, '0103000000010000000500000004560E2DB21D1340DF4F8D976EE2464004560E2DB21D13402FDD240681E5464008AC1C5A643B13402FDD240681E5464008AC1C5A643B1340DF4F8D976EE2464004560E2DB21D1340DF4F8D976EE24640', 'FPSLYO2019', 'NoiseCapture au festival Pop’Sciences : « La Duchère » Party', 'FPSLYO', 'Une NoiseCapture Party est proposée au quartier de la Duchère à Lyon dans le cadre du festival Pop’Sciences organisé par l’Université de Lyon les 17 et 18 mai 2019. Scolaires et grand public pourront découvrir l’application et contribuer à la cartographie participative de l’environnement sonore du quartier.', '2019-05-01 01:00:00+00', '2019-05-31 23:59:59+00', true, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (24, '01030000000100000005000000C1CAA145B6F3D93F4B598638D6554440C1CAA145B6F3D93F265305A3920A4540A3923A014D840740265305A3920A4540A3923A014D8407404B598638D6554440C1CAA145B6F3D93F4B598638D6554440', 'SSSOROLL2019', 'Activitat Cerquem el silenci a ...', 'SSSOROLL2019', 'Dins de la Setmana Sense Soroll 2019, es promou l’activitat de localitzar, identificar i caracteritzar àrees, zones i itineraris tranquils/les acústicament, a nivell urbà, interurbà o que no formin part de l’entramat urbà, com camins rurals, agrícoles, etc..., per tal de disposar d’informació dels diferents espais lliures de soroll. Aquesta activitat es realitzarà amb mòbil i l’app NOISECAPTURE', '2019-04-16 01:00:00+00', '2019-05-30 23:59:59+00', true, false);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (26, '01030000000100000005000000A9DDC5FF958B2D40DDF7D5557C614440A9DDC5FF958B2D40ADBDDCF00F64444094B35E91C99E2D40ADBDDCF00F64444094B35E91C99E2D40DDF7D5557C614440A9DDC5FF958B2D40DDF7D5557C614440', 'UNISA2019', 'University of Salerno 2019', 'UNISA', 'NoiseCapture Party made by the University of Salerno', '2019-05-21 23:59:59+00', '2019-05-25 23:59:59+00', true, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (27, '01030000000100000005000000F88DAF3DB3041F40431CEBE2364A4840F88DAF3DB3041F406C09F9A0674B48406B65C22FF5131F406C09F9A0674B48406B65C22FF5131F40431CEBE2364A4840F88DAF3DB3041F40431CEBE2364A4840', 'FDSSTRAS2019', 'Stras'' NoiseCaptureParty ', 'FDSSTRAS', 'À l''occasion de la Fête de la Science 2019, l''UMRAE vous propose de participer à une NoiseCapture Party. Mesurez l''environnement sonore autour du Village des Sciences de Strasbourg avec votre smartphone et contribuez à l''élaboration d''une carte de bruit en temps réel avec le code #FDSSTRAS. Rendez-vous à 15h les 12 et 13 octobre devant les marches du Palais Universitaire ou du 11 au 13 octobre au stand "Des bruits et des sons" pour plus d''informations. ', '2019-10-10 01:00:00+00', '2019-10-14 23:59:59+00', true, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (28, '0103000000010000000500000033A6608DB33913404F081D7409DF464033A6608DB339134022A5D93C0EE54640575F5D15A875134022A5D93C0EE54640575F5D15A87513404F081D7409DF464033A6608DB33913404F081D7409DF4640', 'H2020Monica_Lyon2019', 'H2020 Monica Fête Des Lumières Party', 'H2020', 'Fête Des Lumières is an event that takes place in Lyon every nights between the 6th and 9th of December. For four nights, the keys of the city are given to different artists who light up buildings, streets, squares and parks. All the city center becomes pedestrian and the sound environment changes with new sources like music or crowd noise.', '2019-12-04 01:00:00+00', '2019-12-09 23:59:59+00', true, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (29, '01030000000100000005000000E9263108ACDC20C046B6F3FDD4A84540E9263108ACDC20C0713D0AD7A3B045405839B4C876BE20C0713D0AD7A3B045405839B4C876BE20C046B6F3FDD4A84540E9263108ACDC20C046B6F3FDD4A84540', 'UDC_2020', 'Contaminación acústica da Universidade da Coruña', 'UDC', 'Descuberta de contaminación acústica: En grupos faremos un mapeado acústico da UDC e da cidade da Coruña, localizando os lugares con contaminación acústica. Traballaremos en grupos e resolveremos ao final da xornada.', '2020-03-01 01:00:00+00', '2020-03-20 23:59:59+00', true, false);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (30, '010300000001000000050000007ADFF8DA33CB1E4021E527D53E4948407ADFF8DA33CB1E40677E3507084A484041BCAE5FB0DB1E40677E3507084A484041BCAE5FB0DB1E4021E527D53E4948407ADFF8DA33CB1E4021E527D53E494840', 'MSA2020', 'Stras'' NoiseCaptureParty ', 'MSA', 'Dans le cadre du parcours de formation "Son - Signal - Information",  l''UMRAE propose de participer à une NoiseCapture Party. Les participants sont invités à mesurer l''environnement sonore autour du Laboratoire de Strasbourg du Cerema avec leur smartphone et à contribuer à l''élaboration d''une carte de bruit en temps réel avec le code #MSA. ', '2020-01-22 00:00:00+00', '2020-01-24 23:59:59+00', true, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (31, '01030000000100000005000000481B47ACC59F53C0B532E197FA79CBBF481B47ACC59F53C0959F54FB743CCABFC9022670EB9E53C0959F54FB743CCABFC9022670EB9E53C0B532E197FA79CBBF481B47ACC59F53C0B532E197FA79CBBF', 'CICAM_EPN2020', 'NoiseCapture Campus Quito', 'CICAM', 'The first edition of the Noise Workshop is aim to sensiblize the <a href="http://www.quitoinforma.gob.ec/2019/10/02/municipio-y-universidades-dan-vida-al-proyecto-urbanistico-campus-quito/" target="_blank">university citadel</a> about the noise pollution and promote the colaboration between universities, students, goverment and general public to tackle the noise problem and promote actions against it.', '2020-04-21 01:00:00+00', '2020-04-26 23:59:59+00', true, false);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (32, '01030000000100000005000000AAF3A8F8BFC322C01500E31934E24440AAF3A8F8BFC322C02387889B53EB45404D10751F80741AC02387889B53EB45404D10751F80741AC01500E31934E24440AAF3A8F8BFC322C01500E31934E24440', 'UDC_COVID_2020', 'Universidade da Coruña - COVID lockdown', 'UDC_COVID', 'Noise measurement campaign, made by UDC, during the COVID lockdown.', '2020-05-04 01:00:00+00', '2020-05-20 23:59:59+00', true, true);
--INSERT INTO public.noisecapture_party (pk_party, the_geom, layer_name, title, tag, description, start_time, end_time, filter_time, filter_area) VALUES (33, '01030000000100000005000000AD69DE718ACE2C40EA95B20C71FC4640AD69DE718ACE2C40C05B2041F1134740295C8FC2F5882D40C05B2041F1134740295C8FC2F5882D40EA95B20C71FC4640AD69DE718ACE2C40EA95B20C71FC4640', 'LJUBLJANA_2020', 'CitieS-Health Ljubljana', 'CHLJ', 'CitieS-Health is a H2020 project (https://citieshealth.eu/) that aims to put citizens’ concerns at the heart of research agenda on environmental epidemiology by tackling health issues that concern them. In Ljubljana, we will investigate how the quality of the living environment (with an emphasis on noise) and living habits affect the (mental) health and well-being of individuals.', '2020-10-01 01:00:00+00', '2021-07-01 23:59:59+00', true, true);



-- Table: NOISECAPTURE_TRACK
CREATE TABLE NOISECAPTURE_TRACK (
    PK_TRACK serial  NOT NULL,
    PK_USER int  NOT NULL REFERENCES noisecapture_user (PK_USER) ON UPDATE CASCADE ON DELETE CASCADE,
    TRACK_UUID char(36)  NOT NULL,
	VERSION_NUMBER int NOT NULL,
	RECORD_UTC timestamptz NOT NULL,
	PLEASANTNESS float,
	DEVICE_PRODUCT text  NOT NULL,
	DEVICE_MODEL text NOT NULL,
	DEVICE_MANUFACTURER text NOT NULL,
	NOISE_LEVEL float NOT NULL,
	TIME_LENGTH float NOT NULL,
	GAIN_CALIBRATION float NOT NULL DEFAULT 0,
	CALIBRATION_METHOD text NOT NULL DEFAULT 'None',
	PK_PARTY int REFERENCES noisecapture_party (PK_PARTY) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT NOISECAPTURE_TRACK_PK PRIMARY KEY (PK_TRACK)
);

COMMENT ON COLUMN NOISECAPTURE_TRACK.NOISE_LEVEL IS 'Sound level in dB(A)';
COMMENT ON COLUMN NOISECAPTURE_TRACK.VERSION_NUMBER IS 'Application version identifier';
COMMENT ON COLUMN NOISECAPTURE_TRACK.PLEASANTNESS IS 'PLEASANTNESS ratio, from 0 to 100';
COMMENT ON COLUMN NOISECAPTURE_TRACK.GAIN_CALIBRATION IS 'Signal gain in dB, provided from user using phone calibration';
COMMENT ON COLUMN NOISECAPTURE_TRACK.TIME_LENGTH IS 'Length of measurement in seconds';

-- Table: NOISECAPTURE_POINT
CREATE TABLE NOISECAPTURE_POINT (
    PK_POINT serial NOT NULL,
    THE_GEOM geometry, -- POSTGIS ONLY the_geom geometry(GeometryZ, 4326),
    PK_TRACK int NOT NULL REFERENCES noisecapture_track (pk_track) ON UPDATE CASCADE ON DELETE CASCADE,
    NOISE_LEVEL float  NOT NULL,
    SPEED float,
    ACCURACY float  NOT NULL,
    ORIENTATION float,
    TIME_DATE timestamptz  NOT NULL,
    TIME_LOCATION timestamptz,
    CONSTRAINT NOISECAPTURE_POINT_PK PRIMARY KEY (PK_POINT)
);

COMMENT ON COLUMN NOISECAPTURE_POINT.ORIENTATION IS 'Device movement bearing, may be null';
COMMENT ON COLUMN NOISECAPTURE_POINT.TIME_LOCATION IS 'Time of acquisition of the localisation';
COMMENT ON COLUMN NOISECAPTURE_POINT.TIME_DATE IS 'Time of the noise level measurement';
COMMENT ON COLUMN NOISECAPTURE_POINT.SPEED IS 'Device speed in m/s. May be null';
COMMENT ON COLUMN NOISECAPTURE_POINT.ACCURACY IS 'Estimated location accuracy in meter';
COMMENT ON COLUMN NOISECAPTURE_POINT.NOISE_LEVEL IS 'Sound level in dB(A)';


-- Table: NOISECAPTURE_FREQ
CREATE TABLE NOISECAPTURE_FREQ (
    PK_POINT int  NOT NULL REFERENCES noisecapture_point (pk_point) ON DELETE CASCADE ON UPDATE CASCADE,
    FREQUENCY smallint  NOT NULL,
    NOISE_LEVEL float NOT NULL   ,
    CONSTRAINT NOISECAPTURE_FREQ_PK PRIMARY KEY (PK_POINT, FREQUENCY)
);

COMMENT ON COLUMN NOISECAPTURE_FREQ.FREQUENCY IS 'Frequency Hz';
COMMENT ON COLUMN NOISECAPTURE_FREQ.NOISE_LEVEL IS 'Sound level in dB(A)';

CREATE TABLE NOISECAPTURE_TAG (
    PK_TAG serial  NOT NULL,
    TAG_NAME text NOT NULL,
    CONSTRAINT NOISECAPTURE_TAG_PK PRIMARY KEY (PK_TAG)
);


CREATE TABLE NOISECAPTURE_TRACK_TAG (
    PK_TRACK int NOT NULL REFERENCES NOISECAPTURE_TRACK (PK_TRACK) ON DELETE CASCADE ON UPDATE CASCADE,
    PK_TAG int NOT NULL REFERENCES NOISECAPTURE_TAG (PK_TAG) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT NOISECAPTURE_TRACK_TAG_PK PRIMARY KEY (PK_TRACK, PK_TAG)
);

-- Table: NOISECAPTURE_PROCESS_QUEUE, tracks inserted but not processed for community map
CREATE TABLE NOISECAPTURE_PROCESS_QUEUE (
    PK_TRACK int PRIMARY KEY REFERENCES noisecapture_track (pk_track) ON DELETE CASCADE ON UPDATE CASCADE
);

COMMENT ON COLUMN NOISECAPTURE_PROCESS_QUEUE.PK_TRACK IS 'Update area that contains this track';

-- Table: NOISECAPTURE_AREA_CLUSTER, Variable size hexagons that contains only the measurement count
CREATE TABLE NOISECAPTURE_AREA_CLUSTER (
    CELL_LEVEL smallint NOT NULL,
    CELL_Q bigint NOT NULL,
    CELL_R bigint NOT NULL,
    THE_GEOM geometry NOT NULL,
    MEASURE_COUNT int NOT NULL,
    CONSTRAINT NOISECAPTURE_AREA_CLUSTER_PK PRIMARY KEY (CELL_LEVEL, CELL_Q, CELL_R)
);

COMMENT ON COLUMN NOISECAPTURE_AREA_CLUSTER.CELL_LEVEL IS 'Hexagonal size exponent 3^n';
COMMENT ON COLUMN NOISECAPTURE_AREA_CLUSTER.CELL_Q IS 'Hexagonal index Q';
COMMENT ON COLUMN NOISECAPTURE_AREA_CLUSTER.CELL_R IS 'Hexagonal index R';
COMMENT ON COLUMN NOISECAPTURE_AREA_CLUSTER.THE_GEOM IS 'Area shape';
COMMENT ON COLUMN NOISECAPTURE_AREA_CLUSTER.MEASURE_COUNT IS 'noisecapture_point entities in this area';

-- Table: NOISECAPTURE_AREA, Post-processed results, merge of measurements in a regular area
CREATE TABLE NOISECAPTURE_AREA (
    PK_AREA serial  NOT NULL,
    CELL_Q bigint NOT NULL,
    CELL_R bigint NOT NULL,
    TZID VARCHAR(255) NOT NULL,
    THE_GEOM geometry NOT NULL,
    LAEQ float NOT NULL,
    LA50 float NOT NULL,
    LDEN float NOT NULL,
	MEAN_PLEASANTNESS float,
    MEASURE_COUNT int NOT NULL,
    FIRST_MEASURE timestamptz NOT NULL,
    LAST_MEASURE timestamptz NOT NULL,
    PK_PARTY int REFERENCES noisecapture_party (PK_PARTY) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT NOISECAPTURE_AREA_PK PRIMARY KEY (PK_AREA)
);

COMMENT ON COLUMN NOISECAPTURE_AREA.CELL_Q IS 'Hexagonal index Q';
COMMENT ON COLUMN NOISECAPTURE_AREA.CELL_R IS 'Hexagonal index R';
COMMENT ON COLUMN NOISECAPTURE_AREA.TZID IS 'TimeZone identifier';
COMMENT ON COLUMN NOISECAPTURE_AREA.THE_GEOM IS 'Area shape';
COMMENT ON COLUMN NOISECAPTURE_AREA.MEASURE_COUNT IS 'noisecapture_point entities in this area';


-- Table: NOISECAPTURE_AREA, Post-processed results, merge of measurements in a regular area
CREATE TABLE NOISECAPTURE_AREA_PROFILE (
    PK_AREA int  NOT NULL,
    HOUR smallint NOT NULL,
    LAEQ real NOT NULL,
    LA50 float NOT NULL,
    UNCERTAINTY smallint DEFAULT 255,
    VARIABILITY real DEFAULT 0,
    CONSTRAINT NOISECAPTURE_AREA_PROFILE_PK PRIMARY KEY (PK_AREA, HOUR),
    CONSTRAINT NOISECAPTURE_AREA_PROFILE_FK FOREIGN KEY (PK_AREA) REFERENCES NOISECAPTURE_AREA (PK_AREA) ON DELETE CASCADE
);

COMMENT ON COLUMN NOISECAPTURE_AREA_PROFILE.HOUR IS 'Hour of estimated value';
COMMENT ON COLUMN NOISECAPTURE_AREA_PROFILE.LAEQ IS 'Laeq on this hour';
COMMENT ON COLUMN NOISECAPTURE_AREA_PROFILE.LA50 IS 'LA50 on this hour';
COMMENT ON COLUMN NOISECAPTURE_AREA_PROFILE.UNCERTAINTY IS 'Uncertainty 0-255';
COMMENT ON COLUMN NOISECAPTURE_AREA_PROFILE.VARIABILITY IS 'Variability in dB(A)';

CREATE TABLE NOISECAPTURE_DUMP_TRACK_ENVELOPE(
    PK_TRACK int NOT NULL REFERENCES NOISECAPTURE_TRACK (PK_TRACK) ON DELETE CASCADE ON UPDATE CASCADE,
    THE_GEOM geometry,
    measure_count bigint);

-- Statistics cache table

CREATE TABLE noisecapture_stats_last_tracks (
    pk_track integer,
    time_length double precision,
    record_utc timestamptz,
    the_geom varchar,
    env varchar,
    start_pt varchar,
    stop_pt varchar,
    name_0 varchar,
    name_1 varchar,
    name_3 varchar,
    pk_party integer
);

--- Add index

CREATE INDEX ki_noisecapture_area_cellq
  ON noisecapture_area(cell_q);
CREATE INDEX ki_noisecapture_area_cellr
  ON noisecapture_area(cell_r);

CREATE INDEX fki_noisecapture_track_pk_user_fk
  ON noisecapture_track(pk_user);

CREATE INDEX fki_noisecapture_point_pk_track_fk
  ON noisecapture_point(pk_track);

CREATE INDEX fki_noisecapture_process_queue_pk_track_fk
  ON noisecapture_process_queue(pk_track);

CREATE INDEX fki_noisecapture_freq_pk_point_fk
  ON noisecapture_freq(pk_point);

-- H2GIS only queries

   CREATE SPATIAL INDEX ON NOISECAPTURE_POINT(THE_GEOM);
   CREATE SPATIAL INDEX ON NOISECAPTURE_AREA(THE_GEOM);
   CREATE SPATIAL INDEX ON NOISECAPTURE_AREA_CLUSTER(THE_GEOM);

 ---- PostGIS only query

 -- CREATE INDEX ON NOISECAPTURE_POINT USING GIST(THE_GEOM);
 -- CREATE INDEX ON NOISECAPTURE_AREA USING GIST(THE_GEOM);
 -- CREATE INDEX ON NOISECAPTURE_AREA_CLUSTER USING GIST(THE_GEOM);

 ---- Force SRID

-- SELECT UpdateGeometrySRID('noisecapture_dump_track_envelope','the_geom',4326);
-- SELECT UpdateGeometrySRID('noisecapture_area','the_geom',4326);
-- SELECT UpdateGeometrySRID('noisecapture_point','the_geom',4326);
-- SELECT UpdateGeometrySRID('noisecapture_area_cluster','the_geom',4326);
