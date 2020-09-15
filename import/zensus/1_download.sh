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
wget --output-document=csv_Bevoelkerung_100m_Gitter.zip \
  --no-clobber --no-directories \
  'https://www.zensus2011.de/SharedDocs/Downloads/DE/Pressemitteilung/DemografischeGrunddaten/csv_Bevoelkerung_100m_Gitter.zip?__blob=publicationFile&v=3'
