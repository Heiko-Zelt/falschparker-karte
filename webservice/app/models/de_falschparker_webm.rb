class DeFalschparkerWebm < ApplicationRecord
  self.table_name = 'de_falschparker_webm'
  self.primary_key = 'osm_id'

  validates :name, presence: true
  validates :ewz, presence: true
  validates :taten, presence: true
  validates :way, presence: true
end
