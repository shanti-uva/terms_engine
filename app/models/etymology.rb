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
  include KmapsEngine::IsCitable
  
  belongs_to :context, polymorphic: true, touch: true

  has_many :etymology_subject_associations, dependent: :destroy
  has_one :etymology_type_association, dependent: :destroy
  has_many :imports, :as => 'item', :dependent => :destroy
  has_many :legacy_citations, -> { where(info_source_type: InfoSource.model_name.name) }, as: :citable, class_name: 'Citation'
  has_many :standard_citations, -> { where.not(info_source_type: InfoSource.model_name.name) }, as: :citable, class_name: 'Citation'
  
  accepts_nested_attributes_for :etymology_type_association 

  def generic_etymology_subject_associations
    etymology_subject_associations.where.not(branch_id: EtymologyTypeAssociation::BRANCH_ID)
  end
  
  def feature
    self.context.feature
  end
end
