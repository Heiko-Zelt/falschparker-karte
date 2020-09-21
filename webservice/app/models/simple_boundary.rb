class SimpleBoundary < ApplicationRecord
  self.primary_key = 'osm_id'
  validates :name, presence: true
  validates :simple_way, presence: true
end
