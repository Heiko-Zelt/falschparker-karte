/usr/bin/psql --echo-all --dbname gis <export.sql
cd /var/exports
zip notices_wgs84.ascii.csv.zip notices_wgs84.ascii.csv
rm notices_wgs84.ascii.csv
