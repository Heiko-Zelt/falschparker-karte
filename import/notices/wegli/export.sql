\COPY (SELECT date::date, charge, street, city, zip, latitude, longitude FROM wegli_notices ORDER BY date) TO '/var/exports/wegli_notices.utf8.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
