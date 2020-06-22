osm2pgsql --create --slim --cache 1000 -G \
--style boundaries.style \
--database gis -H localhost --username postgres --password \
--unlogged --prefix he \
he_relations_type_boundary.pbf
# --hstore --extra-attributes \
