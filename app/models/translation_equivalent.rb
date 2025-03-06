# == Schema Information
#
# Table name: translation_equivalents
#
#  id          :bigint           not null, primary key
#  content     :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  feature_id  :bigint           not null
#  language_id :integer          not null
#
# Indexes
#
#  index_translation_equivalents_on_feature_id  (feature_id)
#
# Foreign Keys
#
#  fk_rails_...  (feature_id => features.id)
#
class TranslationEquivalent < ApplicationRecord
  include KmapsEngine::IsCitable
  
  belongs_to :feature, touch: true
  belongs_to :language
  
  has_many :imports, as: 'item', dependent: :destroy
  has_many :legacy_citations, -> { where(info_source_type: InfoSource.model_name.name) }, as: :citable, class_name: 'Citation'
  has_many :standard_citations, -> { where.not(info_source_type: InfoSource.model_name.name) }, as: :citable, class_name: 'Citation'
  
  def rsolr_document_tags(document, prefix = '')
    prefix_ = prefix.blank? ? '' : "#{prefix}_"
    translation_equivalent_prefix = "#{prefix_}translation_equivalent_#{self.id}"
    document["#{translation_equivalent_prefix}_content_s"] = self.content
    document["#{translation_equivalent_prefix}_language_s"] = self.language.name
    document["#{translation_equivalent_prefix}_language_code_s"] = self.language.code
    citation_references = self.standard_citations.collect { |c| c.bibliographic_reference }
    document["#{translation_equivalent_prefix}_citation_references_ss"] = citation_references if !citation_references.blank?
    info_sources = self.legacy_citations.collect(&:info_source)
    document["#{translation_equivalent_prefix}_source_code_ss"] = info_sources.collect(&:code) if !info_sources.blank?
  end
  
  # Produces a hash of hashes. First level is keyed on language id. Second level on an array of citation_ids.
  def self.grouped_by_language_then_info_sources(feature)
    translations = feature.translation_equivalents.includes(:citations)
    grouped_by_language = {}
    translations.each do |translation|
      if grouped_by_language[translation.language_id].nil?
        grouped_by_language[translation.language_id] = [translation]
      else
        grouped_by_language[translation.language_id] << translation
      end
    end
    grouped_by_language_then_citation = {}
    grouped_by_language.each_pair do |language_id, translations|
      grouped = {}
      translations.each do |translation|
        citation_ids = translation.citations.collect(&:info_source_id).sort
        if grouped[citation_ids].blank?
          grouped[citation_ids] = [translation]
        else
          grouped[citation_ids] << translation
        end
      end
      grouped_by_language_then_citation[language_id] = grouped
    end
    return grouped_by_language_then_citation
  end
end
