# == Schema Information
#
# Table name: passages
#
#  id           :bigint(8)        not null, primary key
#  context_id   :integer          not null
#  context_type :string           not null
#  content      :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Passage < ApplicationRecord
  include KmapsEngine::IsCitable

  belongs_to :context, polymorphic: true

  validates_presence_of :content
end
