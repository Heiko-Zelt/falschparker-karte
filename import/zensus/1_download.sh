#!/bin/bash
echo "DEBUG downloading..."
cd ~/Downloads
wget --output-document=csv_Bevoelkerung_100m_Gitter.zip \
  --no-clobber --no-directories \
  'https://www.zensus2011.de/SharedDocs/Downloads/DE/Pressemitteilung/DemografischeGrunddaten/csv_Bevoelkerung_100m_Gitter.zip?__blob=publicationFile&v=3'
