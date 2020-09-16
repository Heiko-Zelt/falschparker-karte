CREATE MATERIALIZED VIEW notices_wgs84 AS
  SELECT st_setsrid(st_point(wegeheld_notices2.longitude, wegeheld_notices2.latitude), 4326) AS punkt,
    wegeheld_notices2.date,
    wegeheld_notices2.charge_id,
    '1'::character(1) AS src
   FROM wegeheld_notices2
UNION
  SELECT st_setsrid(st_point(wegli_notices2.longitude, wegli_notices2.latitude), 4326) AS punkt,
    wegli_notices2.date,
    wegli_notices2.charge_id,
    '2'::character(1) AS src
   FROM wegli_notices2
WITH DATA;

CREATE MATERIALIZED VIEW notices_webm AS
  SELECT st_transform(notices_wgs84.punkt, 3857) AS punkt,
    notices_wgs84.date,
    notices_wgs84.charge_id,
    notices_wgs84.src
  FROM notices_wgs84
WITH DATA;

CREATE MATERIALIZED VIEW de_falschparker_webm AS
  SELECT poly.osm_id, poly.name, poly.admin_level, poly.ewz, s.taten,
    CASE
      WHEN poly.ewz = 0 THEN NULL::numeric
      ELSE s.taten::bigint::numeric * 100000.0 / poly.ewz::numeric
    END::real AS pro_mil,
    CASE
      WHEN poly.ewz = 0 THEN NULL::integer
      WHEN (s.taten::numeric * 100000.0 / poly.ewz::numeric) < 1::numeric THEN 1
      WHEN (s.taten::numeric * 100000.0 / poly.ewz::numeric) < 2::numeric THEN 2
      WHEN (s.taten::numeric * 100000.0 / poly.ewz::numeric) < 4::numeric THEN 3
      WHEN (s.taten::numeric * 100000.0 / poly.ewz::numeric) < 8::numeric THEN 4
      WHEN (s.taten::numeric * 100000.0 / poly.ewz::numeric) < 15::numeric THEN 5
      WHEN (s.taten::numeric * 100000.0 / poly.ewz::numeric) < 30::numeric THEN 6
      WHEN (s.taten::numeric * 100000.0 / poly.ewz::numeric) < 60::numeric THEN 7
      WHEN (s.taten::numeric * 100000.0 / poly.ewz::numeric) < 120::numeric THEN 8
      WHEN (s.taten::numeric * 100000.0 / poly.ewz::numeric) < 250::numeric THEN 9
      WHEN (s.taten::numeric * 100000.0 / poly.ewz::numeric) < 500::numeric THEN 10
      WHEN (s.taten::numeric * 100000.0 / poly.ewz::numeric) < 1000::numeric THEN 11
      WHEN (s.taten::numeric * 100000.0 / poly.ewz::numeric) < 2000::numeric THEN 12
      WHEN (s.taten::numeric * 100000.0 / poly.ewz::numeric) < 4000::numeric THEN 13
      ELSE 14
    END::smallint AS kategorie,
    poly.way
  FROM de_polygon_ewz_webm poly
    JOIN ( SELECT de_polygon_ewz_webm.osm_id,
      sum(
        CASE
          WHEN notices_webm.punkt IS NULL THEN 0
          ELSE 1
        END)::integer AS taten
      FROM de_polygon_ewz_webm
        LEFT JOIN notices_webm ON st_within(notices_webm.punkt, de_polygon_ewz_webm.way)
        GROUP BY de_polygon_ewz_webm.osm_id) s ON s.osm_id = poly.osm_id
WITH DATA;

CREATE VIEW simple_boundaries AS
  SELECT de_falschparker_webm.osm_id, de_falschparker_webm.name,
    CASE
      WHEN st_npoints(de_falschparker_webm.way) < 100 THEN st_asgeojson(st_transform(de_falschparker_webm.way, 4326))
      WHEN st_npoints(de_falschparker_webm.way) < 1000 THEN st_asgeojson(st_transform(st_simplifypreservetopology(de_falschparker_webm.way, 20::double precision), 4326))
      ELSE st_asgeojson(st_transform(st_simplifypreservetopology(de_falschparker_webm.way, 40::double precision), 4326))
    END AS simple_way
  FROM de_falschparker_webm;

CREATE MATERIALIZED VIEW de_falschparker_level2_webm AS
  SELECT de_falschparker_webm.osm_id,
    de_falschparker_webm.name,
    de_falschparker_webm.kategorie,
    de_falschparker_webm.way
  FROM de_falschparker_webm
  WHERE de_falschparker_webm.admin_level = 2
WITH DATA;

CREATE MATERIALIZED VIEW de_falschparker_level4_webm AS
  SELECT de_falschparker_webm.osm_id,
    de_falschparker_webm.name,
    de_falschparker_webm.kategorie,
    de_falschparker_webm.way
  FROM de_falschparker_webm
  WHERE de_falschparker_webm.admin_level = 4
WITH DATA;

CREATE MATERIALIZED VIEW de_falschparker_level5_webm AS
  SELECT de_falschparker_webm.osm_id,
    de_falschparker_webm.name,
    de_falschparker_webm.kategorie,
    de_falschparker_webm.way
  FROM de_falschparker_webm
  WHERE de_falschparker_webm.admin_level = 5
WITH DATA;
CREATE MATERIALIZED VIEW de_falschparker_level6_webm AS
  SELECT de_falschparker_webm.osm_id,
    de_falschparker_webm.name,
    de_falschparker_webm.kategorie,
    de_falschparker_webm.way
  FROM de_falschparker_webm
  WHERE de_falschparker_webm.admin_level = 6
WITH DATA;
CREATE MATERIALIZED VIEW de_falschparker_level7_webm AS
  SELECT de_falschparker_webm.osm_id,
    de_falschparker_webm.name,
    de_falschparker_webm.kategorie,
    de_falschparker_webm.way
  FROM de_falschparker_webm
  WHERE de_falschparker_webm.admin_level = 7
WITH DATA;
CREATE MATERIALIZED VIEW de_falschparker_level8_webm AS
  SELECT de_falschparker_webm.osm_id,
    de_falschparker_webm.name,
    de_falschparker_webm.kategorie,
    de_falschparker_webm.way
  FROM de_falschparker_webm
  WHERE de_falschparker_webm.admin_level = 8
WITH DATA;

CREATE MATERIALIZED VIEW de_falschparker_level9_webm AS
  SELECT de_falschparker_webm.osm_id,
    de_falschparker_webm.name,
    de_falschparker_webm.kategorie,
    de_falschparker_webm.way
  FROM de_falschparker_webm
  WHERE de_falschparker_webm.admin_level = 9
WITH DATA;

CREATE MATERIALIZED VIEW de_falschparker_level10_webm AS
  SELECT de_falschparker_webm.osm_id,
    de_falschparker_webm.name,
    de_falschparker_webm.kategorie,
    de_falschparker_webm.way
  FROM de_falschparker_webm
  WHERE de_falschparker_webm.admin_level = 10
WITH DATA;

CREATE MATERIALIZED VIEW de_falschparker_level11_webm AS
  SELECT de_falschparker_webm.osm_id,
    de_falschparker_webm.name,
    de_falschparker_webm.kategorie,
    de_falschparker_webm.way
  FROM de_falschparker_webm
  WHERE de_falschparker_webm.admin_level = 11
WITH DATA;

CREATE MATERIALIZED VIEW de_falschparker_level12_webm AS
  SELECT de_falschparker_webm.osm_id,
    de_falschparker_webm.name,
    de_falschparker_webm.kategorie,
    de_falschparker_webm.way
  FROM de_falschparker_webm
  WHERE de_falschparker_webm.admin_level = 12
WITH DATA;

