# == Schema Information
#
# Table name: definitions
#
#  id           :integer          not null, primary key
#  feature_id   :integer          not null
#  language_id  :integer          not null
#  is_public    :boolean          default(FALSE), not null
#  is_primary   :boolean
#  ancestor_ids :string
#  position     :integer          default(0)
#  content      :text             not null
#  author_id    :integer
#  numerology   :integer
#  tense        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Definition < ApplicationRecord
  acts_as_family_tree :node, nil, tree_class: 'DefinitionRelation'
  
  include KmapsEngine::IsCitable
  include KmapsEngine::IsNotable
  
  belongs_to :feature
  belongs_to :language
  belongs_to :author, :class_name => 'AuthenticatedSystem::Person', optional: true
  has_many :definition_subject_associations, dependent: :destroy
  has_many :association_notes, as: :notable, dependent: :destroy
  
  validates_presence_of :feature_id, :content, :language_id
end
