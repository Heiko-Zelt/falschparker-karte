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
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo
echo "INFO  Aktualisiere Views"
cd ..
./refresh_views.sh
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo
echo "INFO  Zeichne heisse Kacheln neu"
./render_hot_meta_tiles.rb
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo
echo "INFO  Export Data for Download"
./export_for_download.sh
