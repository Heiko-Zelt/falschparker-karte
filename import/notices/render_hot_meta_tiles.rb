#!/usr/bin/ruby

require 'pg'

# Renders hotspot tiles.
# These are tiles with more than a specific number of notices.
# The Asumption is, that rendering hotspot tiles takes much longer than rendering tiles with less objects,
# and users are more interessted in hotspots.
# So pre-rendering these tiles should increase performance.

# Optimierung:
#   nicht fuer alle Tiles render-Befehl geben, sondern nur 1 Mal pro Meta-Tile
#   1. Loesung: nachsehen, ob bereit ein Meta-Tile existiert
#   2. Loesung: merken, welche Meta-Tiles schon gerenderd wurden
#   3. Loesung: Mengen-Transformation: benoetigte Tiles -> benoetigte Meta-Tiles
#   4. Loesung: erst existierende Tiles expiren, dann nur expired Tiles neu rendern
#   5. Loesung: Nicht einzelne Tiles betrachten, sondern generell nur Meta-Tiles

# Number of notices required for rendering meta tile
#THRESHOLD = 800
THRESHOLD = 800
#THRESHOLD = 10000

MAX_COORD = 20037508.342789244
MIN_COORD = MAX_COORD * -1

CON = PG.connect :dbname => 'gis'
CON.prepare 'count1', "SELECT COUNT(*) FROM notices_webm WHERE ST_Within(punkt, ST_MakeEnvelope($1, $2, $3, $4, 3857))";

def numberOfNotices(west, east, south, north)
  bind_values = [west, south, east, north]
  rs = CON.exec_prepared 'count1', bind_values
  c = rs[0]['count'].to_i
  puts "count(west=#{west}, east=#{east}, south=#{south}, north=#{north}) => #{c}" 
  return c
end

def renderMeta(z, x, y)
  puts "rendering meta tile #{z}/#{x}/#{y}"
  tX = x * 8
  tY = y * 8
  puts "rendering tiles #{z}/#{tX}..#{tX + 7}/#{tY}..#{tY + 7}"
  # to do: first check if meta tile already exists

  #/usr/bin/render_list -v -a --min-zoom=5 --max-zoom=5 -x 16 -X 20 -y 9 -Y 11 </dev/null
  `/usr/bin/render_list -v -a -t /var/lib/mod_tile/falschparker --min-zoom=#{z} --max-zoom=#{z} -x #{tX} -X #{tX} -y #{tY} -Y #{tY} </dev/null`
end

def renderMetaRecursive(minX, maxX, minY, maxY, zoom, tileX, tileY)
  if numberOfNotices(minX, maxX, minY, maxY) > THRESHOLD
    rendered = 1
    renderMeta(zoom, tileX, tileY)

    midX = (minX + maxX) / 2
    midY = (minY + maxY) / 2
    zoom = zoom + 1

    # Kachel-Koordinaten: Ursprung: links, oben, Richtung unten, rechts
    # Web-Mercator-Koord: Ursprung: mitte, Richtung oben, rechts

    # links, oben
    rendered = rendered + renderMetaRecursive(minX, midX, midY, maxY, zoom, tileX * 2, tileY * 2)

    # rechts, oben
    rendered = rendered + renderMetaRecursive(midX, maxX, midY, maxY, zoom, tileX * 2 + 1, tileY * 2)

    # links, unten
    rendered = rendered + renderMetaRecursive(minX, midX, minY, midY, zoom, tileX * 2, tileY * 2 + 1)

    # rechts, unten 
    rendered = rendered + renderMetaRecursive(midX, maxX, minY, midY, zoom, tileX * 2 + 1, tileY * 2 + 1)
    return rendered
  else
    return 0
  end 
end

start = Time.now
puts "#{start} started"
renderMeta(0, 0, 0)
renderMeta(1, 0, 0)
renderMeta(2, 0, 0)
rendered = renderMetaRecursive(MIN_COORD, MAX_COORD, MIN_COORD, MAX_COORD, 3, 0, 0)
finish = Time.now
diff = (finish - start).to_i
puts "#{finish} finished"
puts
puts "Total number of rendered meta tiles: #{rendered}"
puts "Time required: #{diff} seconds"
