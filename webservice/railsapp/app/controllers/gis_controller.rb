class SuccessResponseBody
  attr_accessor :count, :notices, :boundaries, :boundary, :chargeTypes, :way, :now
      
  def initialize()
    @ok = true
  end
end

class FailureResponseBody
  def initialize(errorMessage)
    @ok = false
    @errorMessage = errorMessage
  end
end

class GisController < ApplicationController

  # Liefert zu einem Punkt, die administrativen Gebiete,
  # in denen er enthalten ist.
  # Das Ergebnis ist sortiert von der niedrigsten zur hoechsten Verwaltungs-Ebene.      
  def info
    lng = params[:lng]
    lat = params[:lat]
    # Wiesbaden Sued-Ost
    #lat=50.076304245905355, lng=8.253908157348635
    logger.debug("lat=" + lat.to_s + ", lng=" + lng.to_s)

#    Macht kein Unterschied. Auf Datenbank-Ebene kommt kein Bind-Parameter an.
#    praedikat = "ST_Within(ST_Transform(ST_SetSRID(ST_Point(:lng, :lat), 4326), 3857), way)"
#    boundaries = DeFalschparkerWebm
#      .select(:osm_id, :name, :ewz, :taten, :admin_level)
#      .where(praedikat, :lng => lng, :lat => lat)
#      .order(admin_level: :desc)

    praedikat = "ST_Within(ST_Transform(ST_SetSRID(ST_Point(?, ?), 4326), 3857), way)"
    boundaries = DeFalschparkerWebm
      .select(:osm_id, :name, :ewz, :taten, :admin_level)
      .where(praedikat, lng, lat)
      .order(admin_level: :desc)

    res = SuccessResponseBody.new()
    res.boundaries = boundaries
    logger.debug("size= " + res.boundaries.size().to_s)
    render json: res 
  end

  # liefert zu einem adminstrativen Gebiet, das Grenz-Multipolygon (und alle anderen Attribute gleich mit)
  # Das Grenz-Multipolygon ist verlustbehaftet komprimiert / vereinfacht.
  def boundary
    osmId = params[:osmid]
    logger.debug("osmid=#{osmId}")
    boundary = SimpleBoundary.find(osmId.to_i)
    if boundary
      res = SuccessResponseBody.new()
      res.way = JSON.parse(boundary.simple_way)
    else
      res = FailureResponseBody.new("Not Found")
    end
    render json: res
  end

  # liefert alle Bundeslaender
  def bundeslaender
    logger.debug("Bundeslaender")
    boundaries = DeFalschparkerWebm
      .select(:osm_id, :name, :ewz, :taten, :pro_mil)
      .where(admin_level: 4)
      .order(pro_mil: :desc)
    res = SuccessResponseBody.new()
    res.boundaries = boundaries
    render json: res 
  end

  # liefert alle Regierungsbezirke
  def regierungsbezirke 
    logger.debug("Regierungsbezirke")
    boundaries = DeFalschparkerWebm
      .select(:osm_id, :name, :ewz, :taten, :pro_mil)
      .where(admin_level: 5)
      .order(pro_mil: :desc)
    res = SuccessResponseBody.new()
    res.boundaries = boundaries
    render json: res 
  end

  # liefert alle Grossstaedte mit den meisten Falschparkern
  def grossstaedte
    logger.debug("Grossstaedte")
    # Hamburg (62782), Berlin (62422), Bremen (62718)
    #
    # .where(:osm_id => [-62782, -62422, -62718]).or(DeFalschparkerWebm.where('ewz > 100000').where(:admin_level => [6, 7, 8]))
    # .where(:osm_id => [62782, 62422, 62718]).or(DeFalschparkerWebm.where('(ewz > 100000) AND admin_level IN (6, 7, 8)'))
    boundaries = DeFalschparkerWebm
      .where(:osm_id => [62782, 62422, 62718]).or(DeFalschparkerWebm.where('ewz > 100000').where(:admin_level => [6, 7, 8]))
      .select(:osm_id, :name, :ewz, :taten, :pro_mil)
      .order(pro_mil: :desc)
      .take(100)
    res = SuccessResponseBody.new()
    res.boundaries = boundaries
    render json: res 
  end

  # Liefert die mittelgroßen Staedte und Gemeinden mit den meisten Falschparkern
  def mittlere_gemeinden
    logger.debug("mittlere Gemeinden")
    boundaries = DeFalschparkerWebm
      .select(:osm_id, :name, :ewz, :taten, :pro_mil)
      .where(:ewz => 20000..99999).where(:admin_level => [6, 7, 8])
      .order(pro_mil: :desc)
      .take(100)
    res = SuccessResponseBody.new()
    res.boundaries = boundaries
    render json: res 
  end

  # Zaehlt die Falschparker-Meldungen innerhalb eines Rechtecks
  def count
    logger.debug("count")
    if params.key?(:w) and params.key?(:e) and params.key?(:s) and params.key?(:n)
      west  = params[:w]
      east  = params[:e]
      south = params[:s]
      north = params[:n]
      logger.debug("W #{west}, E #{east}, S #{south}, N #{north}")
      #count = ResponseBody.within(west, east, south, north).count();
      praedikat = "ST_Within(punkt, ST_MakeEnvelope(:w, :s, :e, :n, 4326))"
      count = Notice
	.where(praedikat, :w => west, :s => south, :e => east, :n => north)
	.count();
      logger.debug("count: #{count}")
      res = SuccessResponseBody.new()
      res.count = count
    else
      res = FailureResponseBody.new("Fehlende GET-Parameter")
    end
    render json: res
  end

  # Liefert wie count die Anzahl der Falschparker-Meldungen.
  # Wenn die Anzahl nicht zu hoch ist, dann auch die vollstaendigen Meldungen.
  def notices
    logger.debug("notices")
    if params.key?(:w) and params.key?(:e) and params.key?(:s) and params.key?(:n)
      west  = params[:w]
      east  = params[:e]
      south = params[:s]
      north = params[:n]
      logger.debug("W #{west}, E #{east}, S #{south}, N #{north}")
      #count = ResponseBody.within(west, east, south, north).count();
      praedikat = "ST_Within(punkt, ST_MakeEnvelope(:w, :s, :e, :n, 4326))"
      count = Notice
        .where(praedikat, :w => west, :s => south, :e => east, :n => north)
        .count();
      logger.debug("count: #{count}")
      res = SuccessResponseBody.new()
      res.count = count
      if count <= 800
	# To do: prepare nur bei Verbindungsaufbau
	conn = ActiveRecord::Base.connection.raw_connection;
        select = "SELECT date, charge_id, ST_X(punkt) AS x, ST_Y(punkt) AS y, src\n" +
          "FROM notices_wgs84\n" +
          "WHERE ST_Within(punkt, ST_MakeEnvelope($1, $2, $3, $4, 4326))\n" +
          "ORDER BY date"
	begin
          conn.prepare('notices', select);
        rescue PG::DuplicatePstatement
          logger.debug("Prepared Statement already exists.");
        end
	logger.debug(select);
	notices = conn.exec_prepared('notices', [west, south, east, north]);
        res.notices = notices
	res.now = Date.today
      end
    else
      res = FailureResponseBody.new("Fehlende GET-Parameter")
    end
    render json: res
  end

  # Liefert einfach die komplette Tabelle
  def charge_types
    logger.debug("charge_types")
    chargeTypes = ChargeType.select(:id, :pin_id, :name)
    res = SuccessResponseBody.new()
    res.chargeTypes = chargeTypes
    render json: res
  end
end
