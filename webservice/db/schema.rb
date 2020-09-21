# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_10_182110) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "de_polygon", primary_key: "osm_id", id: :bigint, default: nil, force: :cascade do |t|
    t.text "name"
    t.integer "admin_level", limit: 2
    t.geometry "way", limit: {:srid=>3857, :type=>"geometry"}
    t.index ["osm_id"], name: "de_polygon_pkey"
    t.index ["way"], name: "de_polygon_index", using: :gist
  end

  create_table "de_polygon_ewz_webm", primary_key: "osm_id", id: :bigint, default: nil, force: :cascade do |t|
    t.text "name"
    t.integer "admin_level", limit: 2
    t.integer "ewz"
    t.geometry "way", limit: {:srid=>3857, :type=>"geometry"}
    t.index ["way"], name: "de_polygon_ewz_webm_way_idx", using: :gist
  end

  create_table "he_falschparker_wgs84", id: false, force: :cascade do |t|
    t.bigint "osm_id", null: false
    t.text "name"
    t.integer "ewz"
    t.integer "taten", limit: 2
    t.float "pro_mil"
    t.integer "kategorie", limit: 2
    t.geometry "way", limit: {:srid=>4326, :type=>"geometry"}
    t.integer "admin_level", limit: 2
  end

  create_table "he_polygon", primary_key: "osm_id", id: :bigint, default: nil, force: :cascade do |t|
    t.text "name"
    t.integer "admin_level", limit: 2
    t.geometry "way", limit: {:srid=>3857, :type=>"geometry"}
    t.index ["osm_id"], name: "he_polygon_pkey"
    t.index ["way"], name: "he_polygon_index", using: :gist
  end

  create_table "he_polygon_ewz_webm", primary_key: "osm_id", id: :bigint, default: nil, force: :cascade do |t|
    t.text "name"
    t.integer "admin_level", limit: 2
    t.integer "ewz"
    t.geometry "way", limit: {:srid=>3857, :type=>"geometry"}
    t.index ["osm_id"], name: "he_polygon_ewz_webm_osm_id_idx"
    t.index ["way"], name: "he_polygon_ewz_webm_way_idx", using: :gist
  end

  create_table "he_polygon_ewz_wgs84", primary_key: "osm_id", id: :bigint, default: nil, force: :cascade do |t|
    t.text "name"
    t.integer "admin_level", limit: 2
    t.integer "ewz"
    t.geometry "way", limit: {:srid=>4326, :type=>"geometry"}
    t.index ["osm_id"], name: "he_polygon_ewz_wgs84_osm_id_idx"
    t.index ["way"], name: "he_polygon_ewz_wgs84_way_idx", using: :gist
  end

  create_table "he_polygon_wgs84", primary_key: "osm_id", id: :bigint, default: nil, comment: "Verwaltungs-Gebiete verschiedener Ebenen vom Bundesland bis zum Stadtteil", force: :cascade do |t|
    t.text "name"
    t.integer "admin_level", limit: 2
    t.geometry "way", limit: {:srid=>4326, :type=>"geometry"}
    t.index ["osm_id"], name: "he_polygon_wgs84_osm_id_idx"
    t.index ["way"], name: "he_polygon_wgs84_way_idx", using: :gist
  end

# Could not dump table "notices" because of following StandardError
#   Unknown type 'time with time zone' for column 'date'

  create_table "planet_osm_line", id: false, force: :cascade do |t|
    t.bigint "osm_id"
    t.text "access"
    t.text "addr:housename"
    t.text "addr:housenumber"
    t.text "addr:interpolation"
    t.text "admin_level"
    t.text "aerialway"
    t.text "aeroway"
    t.text "amenity"
    t.text "barrier"
    t.text "bicycle"
    t.text "bridge"
    t.text "boundary"
    t.text "building"
    t.text "construction"
    t.text "covered"
    t.text "foot"
    t.text "highway"
    t.text "historic"
    t.text "horse"
    t.text "junction"
    t.text "landuse"
    t.integer "layer"
    t.text "leisure"
    t.text "lock"
    t.text "man_made"
    t.text "military"
    t.text "name"
    t.text "natural"
    t.text "oneway"
    t.text "place"
    t.text "power"
    t.text "railway"
    t.text "ref"
    t.text "religion"
    t.text "route"
    t.text "service"
    t.text "shop"
    t.text "surface"
    t.text "tourism"
    t.text "tracktype"
    t.text "tunnel"
    t.text "water"
    t.text "waterway"
    t.float "way_area"
    t.integer "z_order"
    t.hstore "tags"
    t.geometry "way", limit: {:srid=>3857, :type=>"line_string"}
    t.index ["osm_id"], name: "planet_osm_line_pkey"
    t.index ["way"], name: "planet_osm_line_index", using: :gist
  end

  create_table "planet_osm_nodes", id: :bigint, default: nil, force: :cascade do |t|
    t.integer "lat", null: false
    t.integer "lon", null: false
  end

  create_table "planet_osm_point", id: false, force: :cascade do |t|
    t.bigint "osm_id"
    t.text "access"
    t.text "addr:housename"
    t.text "addr:housenumber"
    t.text "admin_level"
    t.text "aerialway"
    t.text "aeroway"
    t.text "amenity"
    t.text "barrier"
    t.text "boundary"
    t.text "building"
    t.text "highway"
    t.text "historic"
    t.text "junction"
    t.text "landuse"
    t.integer "layer"
    t.text "leisure"
    t.text "lock"
    t.text "man_made"
    t.text "military"
    t.text "name"
    t.text "natural"
    t.text "oneway"
    t.text "place"
    t.text "power"
    t.text "railway"
    t.text "ref"
    t.text "religion"
    t.text "shop"
    t.text "tourism"
    t.text "water"
    t.text "waterway"
    t.hstore "tags"
    t.geometry "way", limit: {:srid=>3857, :type=>"st_point"}
    t.index ["osm_id"], name: "planet_osm_point_pkey"
    t.index ["way"], name: "planet_osm_point_index", using: :gist
  end

  create_table "planet_osm_polygon", id: false, force: :cascade do |t|
    t.bigint "osm_id"
    t.text "access"
    t.text "addr:housename"
    t.text "addr:housenumber"
    t.text "addr:interpolation"
    t.text "admin_level"
    t.text "aerialway"
    t.text "aeroway"
    t.text "amenity"
    t.text "barrier"
    t.text "bicycle"
    t.text "bridge"
    t.text "boundary"
    t.text "building"
    t.text "construction"
    t.text "covered"
    t.text "foot"
    t.text "highway"
    t.text "historic"
    t.text "horse"
    t.text "junction"
    t.text "landuse"
    t.integer "layer"
    t.text "leisure"
    t.text "lock"
    t.text "man_made"
    t.text "military"
    t.text "name"
    t.text "natural"
    t.text "oneway"
    t.text "place"
    t.text "power"
    t.text "railway"
    t.text "ref"
    t.text "religion"
    t.text "route"
    t.text "service"
    t.text "shop"
    t.text "surface"
    t.text "tourism"
    t.text "tracktype"
    t.text "tunnel"
    t.text "water"
    t.text "waterway"
    t.float "way_area"
    t.integer "z_order"
    t.hstore "tags"
    t.geometry "way", limit: {:srid=>3857, :type=>"geometry"}
    t.index ["osm_id"], name: "planet_osm_polygon_pkey"
    t.index ["way"], name: "planet_osm_polygon_index", using: :gist
  end

  create_table "planet_osm_rels", id: :bigint, default: nil, force: :cascade do |t|
    t.integer "way_off", limit: 2
    t.integer "rel_off", limit: 2
    t.bigint "parts", array: true
    t.text "members", array: true
    t.text "tags", array: true
    t.index ["parts"], name: "planet_osm_rels_parts", using: :gin
  end

  create_table "planet_osm_roads", id: false, force: :cascade do |t|
    t.bigint "osm_id"
    t.text "access"
    t.text "addr:housename"
    t.text "addr:housenumber"
    t.text "addr:interpolation"
    t.text "admin_level"
    t.text "aerialway"
    t.text "aeroway"
    t.text "amenity"
    t.text "barrier"
    t.text "bicycle"
    t.text "bridge"
    t.text "boundary"
    t.text "building"
    t.text "construction"
    t.text "covered"
    t.text "foot"
    t.text "highway"
    t.text "historic"
    t.text "horse"
    t.text "junction"
    t.text "landuse"
    t.integer "layer"
    t.text "leisure"
    t.text "lock"
    t.text "man_made"
    t.text "military"
    t.text "name"
    t.text "natural"
    t.text "oneway"
    t.text "place"
    t.text "power"
    t.text "railway"
    t.text "ref"
    t.text "religion"
    t.text "route"
    t.text "service"
    t.text "shop"
    t.text "surface"
    t.text "tourism"
    t.text "tracktype"
    t.text "tunnel"
    t.text "water"
    t.text "waterway"
    t.float "way_area"
    t.integer "z_order"
    t.hstore "tags"
    t.geometry "way", limit: {:srid=>3857, :type=>"line_string"}
    t.index ["osm_id"], name: "planet_osm_roads_pkey"
    t.index ["way"], name: "planet_osm_roads_index", using: :gist
  end

  create_table "planet_osm_ways", id: :bigint, default: nil, force: :cascade do |t|
    t.bigint "nodes", null: false, array: true
    t.text "tags", array: true
    t.index ["nodes"], name: "planet_osm_ways_nodes", using: :gin
  end

  create_table "tatorte_webm", id: false, force: :cascade do |t|
    t.geometry "punkt", limit: {:srid=>3857, :type=>"st_point"}
    t.index ["punkt"], name: "tatorte_webm_punkt_idx", using: :gist
  end

  create_table "wegeheld_notices", id: false, force: :cascade do |t|
    t.float "latitude", null: false
    t.float "longitude", null: false
    t.text "carbrand"
    t.datetime "date", null: false
    t.integer "charge", limit: 2
    t.text "fotolink"
    t.index ["latitude", "longitude", "date", "charge", "carbrand", "fotolink"], name: "wegeheld_notices_unique_idx", unique: true
  end

  create_table "wegli_notices", id: false, force: :cascade do |t|
    t.datetime "date", null: false
    t.string "charge", limit: 300, null: false
    t.string "street", limit: 300
    t.string "city", limit: 60
    t.string "zip", limit: 5
    t.float "latitude", null: false
    t.float "longitude", null: false
  end

  create_table "zensus_bevoelkerung", id: :string, limit: 16, force: :cascade do |t|
    t.integer "x"
    t.integer "y"
    t.integer "einwohner", limit: 2
  end

  create_table "zensus_points_webm", id: false, force: :cascade do |t|
    t.integer "einwohner", limit: 2
    t.geometry "punkt", limit: {:srid=>3857, :type=>"st_point"}, null: false
    t.index ["punkt"], name: "zensus_points_webm_punkt_idx", using: :gist
  end

  create_table "zensus_points_wgs84", id: false, force: :cascade do |t|
    t.integer "einwohner", limit: 2
    t.geometry "punkt", limit: {:srid=>4326, :type=>"st_point"}, null: false
    t.index ["punkt"], name: "zensus_points_wgs84_punkt_idx", using: :gist
  end

end
