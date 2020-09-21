class SimpleBoundaries < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          CREATE OR REPLACE VIEW simple_boundaries AS
          SELECT osm_id, name,
          ST_AsGeoJSON(ST_Transform(ST_SimplifyPreserveTopology(way, 40), 4326)) AS simple_way
          FROM de_falschparker_webm;
        SQL
      end
      dir.down do
	execute <<-SQL
	  DROP VIEW IF EXISTS simple_boundaries;
        SQL
      end
    end
  end
end
