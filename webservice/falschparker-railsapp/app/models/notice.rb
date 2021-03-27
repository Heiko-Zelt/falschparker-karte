class Notice < ApplicationRecord
  self.table_name = 'notices_wgs84'
  
  #validates :src, presence: true
  #validates :x, presence: true
  #validates :y, presence: true
end
