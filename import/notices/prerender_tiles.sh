# renders hot tiles
for t in `cat hot_tiles.txt`; do
  wget --no-verbose -O /dev/null --no-check-certificate https://ubuntu.fritz.box/falschparker_tiles/$t.png
  sleep 0.1
done
