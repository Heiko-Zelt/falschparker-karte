# 320 Millionen Knoten * 8 Bytes/Knoten = 2,5 GB aufgerundet 3 GB cache
# reicht aber leider praktisch nur fuer 200 Millionen Knoten
/usr/bin/osm2pgsql --slim --cache 5000 --create --multi-geometry --hstore --number-processes 3 \
  --style ~/src/openstreetmap-carto/openstreetmap-carto.style \
  --tag-transform-script ~/src/openstreetmap-carto/openstreetmap-carto.lua \
  --database gis \
  --host /var/run/postgresql \
  germany-latest.osm.pbf
