#!/usr/bin/ruby

require 'net/http'
require 'uri'

BASE_URI = 'https://weg.li'
INDEX_URI = 'https://weg.li/exports'
PATTERN = 'href\="(/rails/active_storage/blobs/redirect/[A-Za-z0-9]+={0,2}\-\-[0-9a-f]+/(notices-[0-9]{1,2}\.zip)\?disposition\=attachment)"'

# Beispiel:
#<a class="btn btn-sm btn-default" title="herunterladen" href="/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBeUVjQXc9PSIsImV4cCI6bnVsbCwicHVyIjoiYmxvYl9pZCJ9fQ==--6b78fd1878005531fac46fb6350328ba585ecefe/notices-45.zip?disposition=attachment">

def getPathAndFilename(indexUri, pattern)
  puts 'getPathAndFilename()'
  index_uri = URI(indexUri)
  re = Regexp.new pattern
  html = Net::HTTP.get(index_uri)
  puts "DEBUG length of index html page: #{html.length}"
  #puts html
  m = html.match re
  if m then
    path = m[1]
    filename = m[2]
    puts "DEBUG path: #{path}"
    puts "DEBUG filename: #{filename}"
  else
    puts "ERROR Download-Link nicht gefunden!"
    exit 1
  end 
  return [path, filename]
end

def downloadFile(baseUri, path, filename)
  puts 'downloadFile()'
  download_uri = BASE_URI + path
  `/usr/bin/wget -O #{filename} #{download_uri}`
end

def unpack(zipFilename)
  `/usr/bin/unzip -o -d /tmp #{zipFilename}`
end

def import(csvFilename)
  sqlFile = 'import.sql'
  dbName = 'gis'
  sql = "TRUNCATE TABLE public.wegli_notices;\n" +
    "\\COPY public.wegli_notices (date, charge, street, city, zip, latitude, longitude) " +
    "FROM '/tmp/#{csvFilename}' DELIMITER ',' CSV HEADER ENCODING 'UTF8';\n" +
    "CALL refresh_wegli_notices2();\n"
    #"VACUUM ANALYZE public.wegli_notices;" only table owner can vacuum
  puts sql
  File.open(sqlFile, 'w') { |file| file.write(sql) } 
  `/usr/bin/psql --echo-all --dbname gis <#{sqlFile}`
end

def cleanup()
  `/bin/rm /tmp/notices-*.csv`
end 

path, archiveFilename = getPathAndFilename(INDEX_URI, PATTERN)
downloadFile(BASE_URI, path, archiveFilename)
#archiveFilename = 'notices-22.zip'
unpack(archiveFilename)
csvFilename = archiveFilename.sub(/\.zip$/, '.csv')
import(csvFilename)
cleanup()
