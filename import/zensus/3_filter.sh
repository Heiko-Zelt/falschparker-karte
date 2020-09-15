#grep -vE ';-1\r$' Zensus_Bevoelkerung_100m-Gitter.csv > zensus_bevoelkerung.csv
/usr/bin/awk -F ';' -f filter.awk \
  <~/Downloads/Zensus_Bevoelkerung_100m-Gitter.csv \
  >~/Downloads/zensus_bevoelkerung.csv
