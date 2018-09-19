# == Schema Information
#
# Table name: etymologies
#
#  id           :bigint(8)        not null, primary key
#  context_id   :integer          not null
#  context_type :string           not null
#  content      :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Etymology < ApplicationRecord
  belongs_to :context, polymorphic: true

  has_many :etymology_subject_associations, dependent: :destroy
  has_one :etymology_type_association

  validates_presence_of :content
end
