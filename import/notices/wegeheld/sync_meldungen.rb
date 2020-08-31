#!/usr/bin/ruby

require 'json'
require 'net/http'
require 'pg'
require 'uri'

#=begin
#Liest die Namen der Bezirke aus der Datenbank.
#returns Array mit den Namen
#=end
#def get_districts_from_database(con)
#  rs = con.exec_prepared 'select1'
#  districts = []
#  rs.each do |row|
#    #puts row['name']
#    districts << row['name']
#  end
#  return districts
#end

def download_from_website(tag, latMin, latMax, lngMin, lngMax)
  sleep 1
  #falsch fromtime = tag.strftime("%Y-%M-%d")
  fromtime = tag.to_s
  #falsch gedacht untiltime = (tag + 1).to_s
  untiltime = fromtime
  qryStr = "?latmin=#{latMin}&latmax=#{latMax}&lngmin=#{lngMin}&lngmax=#{lngMax}&fromtime=#{fromtime}&untiltime=#{untiltime}"
  baseUrl = "https://api.wegeheld.org/getMarkers.html"
  uri = URI(baseUrl + qryStr)
  puts uri
  content = Net::HTTP.get(uri)
  meldungen = JSON.parse(content)
  #puts meldungen.inspect
  puts "total: " + meldungen['total'].to_s
  #puts "first latitude : " + meldungen['markers'][0][0]
  #puts "first longitude: " + meldungen['markers'][0][1]
  total = meldungen['total']
  size = meldungen['markers'].size
  if total == size
    markers = meldungen['markers']
  else
    puts "Daten unvollstaendig! total: #{total} ist ungleich array size: #{size}"
    latMid = (latMin + latMax) / 2;
    lngMid = (lngMin + lngMax) / 2;
    markersNordWest = download_from_website(tag, latMin, latMid, lngMin, lngMid);
    markersNordOst  = download_from_website(tag, latMin, latMid, lngMid, lngMax);
    markersSuedWest = download_from_website(tag, latMid, latMax, lngMin, lngMid);
    markersSuedOst  = download_from_website(tag, latMid, latMax, lngMid, lngMax);
    markers = markersNordWest + markersNordOst + markersSuedWest + markersSuedOst
  end
  return markers
end

def dumpNotice(notice)
  puts '  latitude : ' + notice[0].to_s
  puts '  longitude: ' + notice[1].to_s
  puts '  carbrand : ' + notice[2]
  puts '  fotolink : ' + notice[3]
  puts '  date     : ' + notice[4].to_s
  puts '  charge_id: ' + notice[5].to_s
end

def delete(con, from, to)
  bind_values = [from, to]
  rs = con.exec_prepared 'delete1', bind_values
  num_deleted = rs.cmd_tuples()
  puts "deleted: #{num_deleted}"
end

def upload_to_database(con, markers)
  uploaded = 0
  puts 'uploading ' + markers.length.to_s
  uniViolations = 0
  checkViolations = 0
  begin
    markers.each do |marker|
      fields = marker.size
      if fields == 6
        bind_values = [marker[0], marker[1], marker[2], marker[3], marker[4], marker[5]]
        begin
          rs = con.exec_prepared 'insert1', bind_values
          uploaded += 1;
        rescue PG::UniqueViolation
          #puts 'ist schon drin!'
          #dumpNotice(meldung)
          uniViolations += 1;
        rescue PG::CheckViolation
          #puts 'ungueltig!'
          #dumpNotice(meldung)
          checkViolations += 1;
        end
      else
        puts "ERROR Anzahl Felder ungleich 6 naemlich #{fields}!"
        puts marker.inspect
      end
    end
    puts "uploaded sucessful: #{uploaded}"
    puts "unique violations : #{uniViolations}"   unless uniViolations   == 0
    puts "check  violations : #{checkViolations}" unless checkViolations == 0
  rescue PG::Error => e
    puts e.inspect
    puts e.message
  end
  return uploaded
end

#SELECT MAX(date) FROM wegeheld_notices2;
# very fist day FIRST_DAY = Date.new(2014, 3, 25)
#FIRST_DAY = Date.new(2020, 6, 10)
#LAST_DAY  = Date.new(2020, 1, 3)
FIRST_DAY = Date.today - 7
LAST_DAY = Date.today - 1
CON = PG.connect :dbname => 'gis'
CON.prepare 'delete1', "DELETE FROM wegeheld_notices WHERE date BETWEEN $1 AND $2";
CON.prepare 'insert1', "INSERT INTO wegeheld_notices (latitude, longitude, carbrand, fotolink, date, charge_id) VALUES ($1, $2, $3, $4, $5, $6);"
CON.prepare 'refresh1', "CALL refresh_wegeheld_notices2();"

puts "Zeitraum #{FIRST_DAY.to_s}..#{LAST_DAY.to_s}"
totalDownloaded = 0
totalUploadedSuccessful = 0
delete(CON, FIRST_DAY, LAST_DAY + 1)
(FIRST_DAY..LAST_DAY).each do |tag|
  markers = download_from_website(tag, 47.0, 56.0, 5.0, 16.0)
  totalDownloaded += markers.size
  #puts meldungen.inspect
  uploaded = upload_to_database(CON, markers)
  totalUploadedSuccessful += uploaded
end
rs = CON.exec_prepared 'refresh1'

CON.close() if CON 
puts "Total markers downloaded: #{totalDownloaded}"
puts "Total uploaded sucessful: #{totalUploadedSuccessful}"
