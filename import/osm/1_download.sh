#!/bin/bash
stat ~/Downloads
rc=$?
if [[ $rc != 0 ]]; then
  echo "DEBUG Creating directory for downloads."
  mkdir ~/Downloads
  chmod 0770 ~/Downloads
else
  echo "DEBUG ~/Downloads exists."
fi

echo "DEBUG downloading..."
cd ~/Downloads
wget http://download.geofabrik.de/europe/germany-latest.osm.pbf
#  --output-document=~/Downloads/germany-latest.osm.pbf --no-clobber --no-directories
