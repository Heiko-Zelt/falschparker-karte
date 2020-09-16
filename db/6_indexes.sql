CREATE UNIQUE INDEX charge_types_id_idx
  ON charge_types USING btree (id ASC NULLS LAST);

CREATE UNIQUE INDEX de_polygon_osm_id_idx
  ON de_polygon USING btree (osm_id ASC NULLS LAST);

CREATE INDEX de_polygon_way_idx
  ON de_polygon USING gist (way);

CREATE UNIQUE INDEX de_polygon2_osm_id_idx
  ON de_polygon2 USING btree (osm_id ASC NULLS LAST);
CREATE INDEX de_polygon2_way_idx
  ON de_polygon2 USING gist (way);

CREATE UNIQUE INDEX de_polygon_ewz_webm_osm_id_idx
  ON de_polygon_ewz_webm USING btree (osm_id ASC NULLS LAST);
CREATE INDEX de_polygon_ewz_webm_way_gist
  ON de_polygon_ewz_webm USING gist (way);

-- only to eliminate duplicates
CREATE UNIQUE INDEX wegeheld_notices2_unique_idx
  ON wegeheld_notices2 USING btree (
    latitude ASC NULLS LAST,
    longitude ASC NULLS LAST,
    date ASC NULLS LAST,
    charge_id ASC NULLS LAST,
    carbrand ASC NULLS LAST,
    fotolink ASC NULLS LAST
  );

CREATE INDEX zensus_points_webm_punkt_idx
  ON zensus_points_webm USING gist (punkt);

CREATE INDEX notices_webm_punkt_idx
  ON notices_webm USING gist (punkt);

CREATE INDEX notices_wgs84_punkt_idx
  ON notices_wgs84 USING gist (punkt);

CREATE UNIQUE INDEX de_falschparker_webm_osm_id_idx
  ON de_falschparker_webm USING btree (osm_id);
CREATE INDEX de_falschparker_webm_way_idx
  ON de_falschparker_webm USING gist (way);

CREATE UNIQUE INDEX de_falschparker_level2_webm_osm_id_idx
  ON de_falschparker_level2_webm USING btree (osm_id);
CREATE INDEX de_falschparker_level2_webm_way_idx
  ON de_falschparker_level2_webm USING gist (way);

CREATE UNIQUE INDEX de_falschparker_level4_webm_osm_id_idx
  ON de_falschparker_level4_webm USING btree (osm_id);
CREATE INDEX de_falschparker_level4_webm_way_idx
  ON de_falschparker_level4_webm USING gist (way);

CREATE UNIQUE INDEX de_falschparker_level5_webm_osm_id_idx
  ON de_falschparker_level5_webm USING btree (osm_id);
CREATE INDEX de_falschparker_level5_webm_way_idx
  ON de_falschparker_level5_webm USING gist (way);

CREATE UNIQUE INDEX de_falschparker_level6_webm_osm_id_idx
  ON de_falschparker_level6_webm USING btree (osm_id);
CREATE INDEX de_falschparker_level6_webm_way_idx
  ON de_falschparker_level6_webm USING gist (way);

CREATE UNIQUE INDEX de_falschparker_level7_webm_osm_id_idx
  ON de_falschparker_level7_webm USING btree (osm_id);
CREATE INDEX de_falschparker_level7_webm_way_idx
  ON de_falschparker_level7_webm USING gist (way);

CREATE UNIQUE INDEX de_falschparker_level8_webm_osm_id_idx
  ON de_falschparker_level8_webm USING btree (osm_id);
CREATE INDEX de_falschparker_level8_webm_way_idx
  ON de_falschparker_level8_webm USING gist (way);

CREATE UNIQUE INDEX de_falschparker_level9_webm_osm_id_idx
  ON de_falschparker_level9_webm USING btree (osm_id);
CREATE INDEX de_falschparker_level9_webm_way_idx
  ON de_falschparker_level9_webm USING gist (way);

CREATE UNIQUE INDEX de_falschparker_level10_webm_osm_id_idx
  ON de_falschparker_level10_webm USING btree (osm_id);
CREATE INDEX de_falschparker_level10_webm_way_idx
  ON de_falschparker_level10_webm USING gist (way);

CREATE UNIQUE INDEX de_falschparker_level11_webm_osm_id_idx
  ON de_falschparker_level11_webm USING btree (osm_id);
CREATE INDEX de_falschparker_level11_webm_way_idx
  ON de_falschparker_level11_webm USING gist (way);

CREATE UNIQUE INDEX de_falschparker_level12_webm_osm_id_idx
  ON de_falschparker_level12_webm USING btree (osm_id);
CREATE INDEX de_falschparker_level12_webm_way_idx
  ON de_falschparker_level12_webm USING gist (way);


