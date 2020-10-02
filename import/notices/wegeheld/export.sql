\COPY (SELECT latitude, longitude, carbrand, date::date, charge_id, fotolink FROM wegeheld_notices ORDER BY date) TO '/var/exports/wegeheld_notices.utf8.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
