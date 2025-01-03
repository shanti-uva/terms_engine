# == Schema Information
#
# Table name: enumerations
#
#  id           :bigint           not null, primary key
#  context_type :string           not null
#  value        :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  context_id   :integer          not null
#
class Enumeration < ApplicationRecord
  
  belongs_to :context, polymorphic: true, touch: true # Feature, Definition
  validates_presence_of :context_id, :context_type, :value

end
  
