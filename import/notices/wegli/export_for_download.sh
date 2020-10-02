/usr/bin/psql --echo-all --dbname gis <export.sql
cd /var/exports
zip wegli_notices.utf8.csv.zip wegli_notices.utf8.csv
rm wegli_notices.utf8.csv
