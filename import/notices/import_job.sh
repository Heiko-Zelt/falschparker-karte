#!/bin/bash
echo
echo "INFO  Import Wegeheld-Meldungen"
cd wegeheld
./sync_meldungen.rb
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo
echo "INFO  Import weg-li-Meldungn"
cd ../wegli
./sync_meldungen.rb

echo
echo "INFO  Aktualisiere Views"
cd ..
./refresh_views.sh

echo
echo "INFO  Zeichne heisse Kacheln neu"
./prerender_tiles.sh
