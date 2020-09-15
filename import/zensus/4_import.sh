cd ~/Downloads
psql --dbname gis --command "\\copy public.zensus_bevoelkerung (x, y, einwohner) FROM 'zensus_bevoelkerung.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8'"
