# == Schema Information
#
# Table name: etymologies
#
#  id           :bigint           not null, primary key
#  content      :text
#  context_type :string           not null
#  derivation   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  context_id   :integer          not null
#

class Etymology < ApplicationRecord
  include KmapsEngine::IsNotable

  belongs_to :context, polymorphic: true

  has_many :etymology_subject_associations, dependent: :destroy
  has_one :etymology_type_association, dependent: :destroy

  accepts_nested_attributes_for :etymology_type_association 

  def generic_etymology_subject_associations
    etymology_subject_associations.where.not(branch_id: EtymologyTypeAssociation::BRANCH_ID)

  end
end
