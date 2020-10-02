/usr/bin/psql --echo-all --dbname gis <export.sql
cd /var/exports
zip charge_types.utf8.csv.zip charge_types.utf8.csv
rm charge_types.utf8.csv
