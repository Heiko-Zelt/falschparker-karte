CREATE OR REPLACE PROCEDURE refresh_de_polygon2()
LANGUAGE 'plpgsql'
SECURITY DEFINER
AS $BODY$
BEGIN
  TRUNCATE TABLE de_polygon2;
  INSERT INTO de_polygon2
  SELECT osm_id * -1 AS osm_id, name, admin_level, way
  FROM de_polygon
  WHERE osm_id < 0
  AND ST_Within(way, (
    SELECT way FROM de_polygon
    WHERE name = 'Deutschland')
  );
  ANALYZE de_polygon2;
END; $BODY$;

CREATE OR REPLACE PROCEDURE refresh_de_polygon_ewz_webm()
LANGUAGE 'plpgsql'
SECURITY DEFINER
AS $BODY$
BEGIN
  TRUNCATE de_polygon_ewz_webm;
  INSERT INTO de_polygon_ewz_webm (osm_id, name, admin_level, way, ewz)
  SELECT poly.osm_id, poly.name, poly.admin_level, poly.way,
    SUM(COALESCE(poi.einwohner, 0)) as ewz
  FROM de_polygon2 poly LEFT JOIN zensus_points_webm poi
  ON ST_Within(poi.punkt, poly.way)
  GROUP BY poly.osm_id;
  ANALYZE de_polygon_ewz_webm;
END; $BODY$;

CREATE OR REPLACE PROCEDURE refresh_views()
LANGUAGE 'plpgsql'
SECURITY DEFINER
AS $BODY$
BEGIN
  -- CONCURRENTLY funktioniert leider nicht, weil kein Primaer-Schluessel existiert.
  REFRESH MATERIALIZED VIEW notices_wgs84;
  ANALYZE VERBOSE notices_wgs84;
  REFRESH MATERIALIZED VIEW notices_webm;
  ANALYZE VERBOSE notices_webm;
  REFRESH MATERIALIZED VIEW CONCURRENTLY de_falschparker_webm;
  ANALYZE VERBOSE de_falschparker_webm;
  REFRESH MATERIALIZED VIEW CONCURRENTLY de_falschparker_level2_webm;
  ANALYZE VERBOSE de_falschparker_level2_webm;
  REFRESH MATERIALIZED VIEW CONCURRENTLY de_falschparker_level4_webm;
  ANALYZE VERBOSE de_falschparker_level4_webm;
  REFRESH MATERIALIZED VIEW CONCURRENTLY de_falschparker_level5_webm;
  ANALYZE VERBOSE de_falschparker_level5_webm;
  REFRESH MATERIALIZED VIEW CONCURRENTLY de_falschparker_level6_webm;
  ANALYZE VERBOSE de_falschparker_level6_webm;
  REFRESH MATERIALIZED VIEW CONCURRENTLY de_falschparker_level7_webm;
  ANALYZE VERBOSE de_falschparker_level7_webm;
  REFRESH MATERIALIZED VIEW CONCURRENTLY de_falschparker_level8_webm;
  ANALYZE VERBOSE de_falschparker_level8_webm;
  REFRESH MATERIALIZED VIEW CONCURRENTLY de_falschparker_level9_webm;
  ANALYZE VERBOSE de_falschparker_level9_webm;
  REFRESH MATERIALIZED VIEW CONCURRENTLY de_falschparker_level10_webm;
  ANALYZE VERBOSE de_falschparker_level10_webm;
  REFRESH MATERIALIZED VIEW CONCURRENTLY de_falschparker_level11_webm;
  ANALYZE VERBOSE de_falschparker_level11_webm;
  REFRESH MATERIALIZED VIEW CONCURRENTLY de_falschparker_level12_webm;
  ANALYZE VERBOSE de_falschparker_level12_webm;
END; $BODY$;

CREATE OR REPLACE PROCEDURE refresh_wegeheld_notices2()
LANGUAGE 'plpgsql'
SECURITY DEFINER 
AS $BODY$
DECLARE
   n RECORD;
   cur CURSOR FOR
     SELECT * from wegeheld_notices;
   num_duplicates INTEGER;
   num_origins INTEGER;
   num_oks INTEGER;
BEGIN
  RAISE NOTICE 'begin';
  TRUNCATE wegeheld_notices2;
  num_duplicates = 0;
  num_origins = 0;
  num_oks = 0;
  FOR n IN cur LOOP
    IF n.latitude = 0 AND n.longitude = 0 THEN
      num_origins = num_origins + 1;
    ELSIF EXISTS(
      SELECT * FROM wegeheld_notices2 WHERE n.latitude = latitude
        AND n.longitude = longitude
        AND n.carbrand = carbrand
        AND n.date = date
        AND n.charge_id = charge_id
        AND n.fotolink = fotolink) THEN
          num_duplicates = num_duplicates + 1;
    ELSE
      INSERT INTO wegeheld_notices2 (latitude, longitude, carbrand, date, charge_id, fotolink)
      VALUES (n.latitude, n.longitude, n.carbrand, n.date, n.charge_id, n.fotolink);
      num_oks = num_oks + 1;
    END IF;  
  END LOOP;
  RAISE NOTICE 'finished :-)';
  ANALYZE VERBOSE wegeheld_notices2;
  RAISE NOTICE 'ok:         %', num_oks;
  RAISE NOTICE 'origin:     %', num_origins;
  RAISE NOTICE 'duplicates: %', num_duplicates;
END; $BODY$;

CREATE OR REPLACE PROCEDURE refresh_wegli_notices2()
LANGUAGE 'plpgsql'
SECURITY DEFINER 
AS $BODY$
DECLARE
  cur CURSOR FOR
    SELECT DISTINCT charge
    FROM wegli_notices
    WHERE NOT charge IN (
      SELECT DISTINCT name FROM charge_types
    );
BEGIN
  FOR x in cur LOOP
    RAISE NOTICE 'unknown charge: %', x.charge;
  END LOOP;
  IF NOT EXISTS (
    SELECT DISTINCT charge
    FROM wegli_notices
    WHERE NOT charge IN (
      SELECT DISTINCT name FROM charge_types
    )
  ) THEN
    TRUNCATE wegli_notices2;
    INSERT INTO wegli_notices2 (date, charge_id, street, city, zip, latitude, longitude)
    SELECT n.date, t.id, n.street, n.city, n.zip, n.latitude, n.longitude
    FROM wegli_notices AS n INNER JOIN charge_types AS t ON n.charge = t.name
    WHERE date between '01-01-2019' AND now()
      AND longitude IS NOT NULL AND latitude IS NOT NULL;
    ANALYZE VERBOSE wegli_notices2;	
  END IF;
END; $BODY$;

CREATE OR REPLACE PROCEDURE refresh_zensus_points_webm()
LANGUAGE 'plpgsql'
SECURITY DEFINER
AS $BODY$
BEGIN
  -- Transformation von ETRS89-extended / LAEA Europe nach WebMercator:
  TRUNCATE zensus_points_webm;
  INSERT INTO zensus_points_webm (einwohner, punkt)
  SELECT einwohner, ST_Transform(ST_SetSRID(ST_Point(x, y), 3035), 3857)
  FROM zensus_bevoelkerung;
  ANALYZE zensus_points_webm;
END; $BODY$;

