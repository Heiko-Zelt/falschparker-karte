/usr/bin/psql --echo-all --dbname gis <export.sql
cd /var/exports
zip wegeheld_notices.utf8.csv.zip wegeheld_notices.utf8.csv
rm wegeheld_notices.utf8.csv
