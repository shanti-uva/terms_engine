# == Schema Information
#
# Table name: definitions
#
#  id           :bigint           not null, primary key
#  ancestor_ids :string
#  content      :text             not null
#  is_primary   :boolean
#  is_public    :boolean          default(FALSE), not null
#  numerology   :integer
#  position     :integer          default(0)
#  tense        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  author_id    :integer
#  feature_id   :integer          not null
#  language_id  :integer          not null
#

class Definition < ApplicationRecord
  acts_as_family_tree :node, nil, tree_class: 'DefinitionRelation'
  
  include KmapsEngine::IsCitable
  include KmapsEngine::IsNotable
  include TermsEngine::HasPassages
  include TermsEngine::HasModelSentences
  
  validates_presence_of :feature_id, :language_id
  
  belongs_to :feature, touch: true
  belongs_to :language
  belongs_to :author, class_name: 'AuthenticatedSystem::Person', optional: true
  has_many :association_notes, as: :notable, dependent: :destroy
  has_many :definition_associations, dependent: :destroy
  has_many :definition_subject_associations, dependent: :destroy
  has_many :etymologies, as: :context, dependent: :destroy
  has_many :imports, as: 'item', dependent: :destroy
  has_many :parent_definition_associations, class_name: 'DefinitionAssociation', as: :associated, dependent: :destroy
  has_many :passage_translations, as: :context, dependent: :destroy
  #has_many :legacy_citations, -> { where(info_source_type: InfoSource.model_name.name).joins(:info_source).where('info_sources.processed' => false) }, as: :citable, class_name: 'Citation'
  #has_many :in_house_citations, -> { where(info_source_type: InfoSource.model_name.name).joins(:info_source).where('info_sources.processed' => true) }, as: :citable, class_name: 'Citation'
  has_many :non_standard_citations, -> { where(info_source_type: InfoSource.model_name.name) }, as: :citable, class_name: 'Citation'
  has_many :standard_citations, -> { where.not(info_source_type: InfoSource.model_name.name) }, as: :citable, class_name: 'Citation'
  
  def legacy_citations
    self.non_standard_citations.reject{|c| c.info_source.processed} #. , -> { where(info_source_type: InfoSource.model_name.name).joins(:info_source).where('info_sources.processed' => false) }, as: :citable, class_name: 'Citation'
  end
  
  def in_house_citations
    self.non_standard_citations.select{|c| c.info_source.processed} #, -> { where(info_source_type: InfoSource.model_name.name).joins(:info_source).where('info_sources.processed' => true) }, as: :citable, class_name: 'Citation'
  end
  
  
  def recursive_roots_with_path(path_prefix = [])
    path = path_prefix + [self.id]
    res = [[self, path]]
    self.children.order(:position).where(is_public: true).collect{ |r| res += r.recursive_roots_with_path(path) }
    res
  end
  
  def self.search(filter_value)
    self.where(build_like_conditions(%W(definitions.content definitions.etymology), filter_value))
  end
  
  def self.uid_prefix
    'definitions'
  end

  def snippet(length = 40)
    ActionController::Base.helpers.strip_tags(content).squish.truncate(length)
  end
  
  def writing_system
    case self.language.code
    when 'eng', 'fre', 'deu', 'ita', 'spa', 'san' # this will have to be revised once devanagari is added for sanskrit.
      return WritingSystem.get_by_code('latin')
    when 'zho'
      return WritingSystem.get_by_code('hant') # when needed can see https://github.com/jpatokal/script_detector for distinguishing simplified and trad.
    when 'bod'
      return WritingSystem.get_by_code('tibt')
    when 'hin', 'nep'
      return WritingSystem.get_by_code('deva')
    when 'dzo'
      return WritingSystem.get_by_code('dzongkha')
    end
  end
end
