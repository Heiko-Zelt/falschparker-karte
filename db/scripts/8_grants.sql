GRANT CONNECT ON DATABASE gis TO importeur;
GRANT CREATE, USAGE ON SCHEMA public TO importeur;
GRANT INSERT, UPDATE, DELETE, TRUNCATE, SELECT ON charge_types TO importeur;
GRANT SELECT ON notices_wgs84 TO importeur;

GRANT CONNECT ON DATABASE gis TO railsapp;
GRANT USAGE ON SCHEMA public TO railsapp;
GRANT SELECT ON
  notices_wgs84,
  de_falschparker_webm,
  simple_boundaries,
  charge_types,
  schema_migrations
  TO railsapp;

GRANT CONNECT ON DATABASE gis TO renderd;
GRANT USAGE ON SCHEMA public TO renderd;
GRANT SELECT ON
  notices_webm,
  de_falschparker_level2_webm,
  de_falschparker_level4_webm,
  de_falschparker_level5_webm,
  de_falschparker_level6_webm,
  de_falschparker_level7_webm,
  de_falschparker_level8_webm,
  de_falschparker_level9_webm,
  de_falschparker_level10_webm,
  de_falschparker_level11_webm,
  de_falschparker_level12_webm
  TO renderd;
