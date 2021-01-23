# Berechnet, welche Meta Tiles viele Falschparker-Meldungen enthalten
# und renderd diese Meta Tiles.
# parallelizing speeds up rendering

# -v = verbose
#./calculate_hot_meta_tiles.rb | /usr/bin/render_list -v --num-threads=6 --tile-dir /var/lib/mod_tile/falschparker --min-zoom=0 --force
./calculate_hot_meta_tiles.rb | /usr/bin/render_list --num-threads=6 --tile-dir /var/lib/mod_tile/falschparker --min-zoom=0 --force
