\COPY (SELECT id, pin_id, name FROM charge_types ORDER BY id) TO '/var/exports/charge_types.utf8.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
