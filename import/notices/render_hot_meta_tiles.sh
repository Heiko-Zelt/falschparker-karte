# Berechnet, welche Meta Tiles viele Falschparker-Meldungen enthalten
# und renderd diese Meta Tiles.
./calculate_hot_meta_tiles.rb | /usr/bin/render_list -v --num-threads=6 --tile-dir /var/lib/mod_tile/falschparker --min-zoom=0 --force
