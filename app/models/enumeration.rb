class Enumeration < ApplicationRecord
  
  belongs_to :feature, touch: true
  validates_presence_of :feature_id, :value

end
  
