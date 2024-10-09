class Enumeration < ApplicationRecord
  
  belongs_to :context, polymorphic: true, touch: true # Feature, Definition
  validates_presence_of :context_id, :context_type, :value

end
  
