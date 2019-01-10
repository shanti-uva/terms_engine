# == Schema Information
#
# Table name: definitions
#
#  id           :bigint(8)        not null, primary key
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
  include KmapsEngine::HasPassages
  include TermsEngine::HasModelSentences
  
  belongs_to :feature
  belongs_to :language
  belongs_to :author, :class_name => 'AuthenticatedSystem::Person', optional: true
  has_many :definition_subject_associations, dependent: :destroy
  has_many :association_notes, as: :notable, dependent: :destroy
  has_many :legacy_citations, -> { where(info_source_type: InfoSource.model_name.name) }, as: :citable, class_name: 'Citation'
  
  validates_presence_of :feature_id, :content, :language_id
  
  def recursive_roots_with_path(path_prefix = [])
    path = path_prefix + [self.id]
    res = [[self, path]]
    self.children.order(:position).where(is_public: true).collect{ |r| res += r.recursive_roots_with_path(path) }
    res
  end
  
  def self.uid_prefix
    'definitions'
  end
end
