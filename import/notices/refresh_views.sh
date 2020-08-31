#!/bin/bash
echo "CALL refresh_views();" | /usr/bin/psql --echo-all --dbname gis
sudo /root/empty_tile_cache.sh
