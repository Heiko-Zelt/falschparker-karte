CREATE TABLE charge_types (
  id smallint NOT NULL,
  pin_id smallint NOT NULL,
  name text NOT NULL,
  CONSTRAINT charge_types_pkey PRIMARY KEY (id)
);
COMMENT ON TABLE charge_types
  IS 'catalog table with IDs: wegeheld 1...28, weg-li 101...';

-- should have primary key, but hasn't
CREATE TABLE wegeheld_notices (
  latitude double precision,
  longitude double precision,
  carbrand text,
  date timestamp with time zone,
  charge_id smallint,
  fotolink text
);
COMMENT ON TABLE wegeheld_notices
  IS 'unfiltered imported records from Wegeheld';

CREATE TABLE wegeheld_notices2 (
  latitude double precision NOT NULL,
  longitude double precision NOT NULL,
  carbrand text,
  date timestamp with time zone NOT NULL,
  charge_id smallint,
  fotolink text,
  CONSTRAINT wegeheld_notices CHECK
    (NOT (latitude = 0.0::double precision AND longitude = 0.0::double precision)),
  CONSTRAINT wegeheld_notices2_charge_fkey FOREIGN KEY (charge_id)
    REFERENCES charge_types (id)
);
COMMENT ON TABLE wegeheld_notices2
  IS 'filtered, validated Wegeheld data';

-- should have primary key, but hasn't
CREATE TABLE wegli_notices (
  date timestamp with time zone,
  charge character varying(300),
  street character varying(300),
  city character varying(100),
  zip character varying(5),
  latitude double precision,
  longitude double precision
);
COMMENT ON TABLE wegli_notices
  IS 'unfiltered imported records from weg-li'; 

CREATE TABLE wegli_notices2 (
    date timestamp with time zone NOT NULL,
    street character varying(300),
    city character varying(100),
    zip character varying(5),
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    charge_id smallint NOT NULL,
    CONSTRAINT wegli_notices2_charge_fkey FOREIGN KEY (charge_id)
      REFERENCES charge_types (id)
);
COMMENT ON TABLE wegli_notices2
  IS 'filtered, validated weg-li data';

-- will be created by import script
--CREATE TABLE public.de_polygon (
--    osm_id bigint,
--    name text,
--    admin_level smallint,
--    way geometry(Geometry,3857)
--)

CREATE TABLE de_polygon2 (
  osm_id bigint NOT NULL,
  name text,
  admin_level smallint,
  way geometry(Geometry,3857),
  CONSTRAINT de_polygon2_pkey PRIMARY KEY (osm_id)
);

CREATE TABLE zensus_bevoelkerung (
  x integer,
  y integer,
  einwohner smallint
);

CREATE TABLE zensus_points_webm (
  einwohner smallint,
  punkt geometry(Point,3857) NOT NULL
);

CREATE TABLE de_polygon_ewz_webm (
  osm_id bigint NOT NULL,
  name text,
  admin_level smallint,
  ewz integer,
  way geometry(Geometry,3857),
  CONSTRAINT de_polygon_ewz_pkey PRIMARY KEY (osm_id)
);

