# == Schema Information
#
# Table name: translation_equivalents
#
#  id           :bigint           not null, primary key
#  content      :string
#  context_type :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  context_id   :bigint
#  language_id  :integer          not null
#
# Indexes
#
#  index_translation_equivalents_on_context_type_and_context_id  (context_type,context_id)
#
class TranslationEquivalent < ApplicationRecord
  include KmapsEngine::IsCitable
  
  belongs_to :feature
  belongs_to :language
  
  has_many :imports, as: 'item', dependent: :destroy
  
  def rsolr_document_tags(document, prefix = '')
    prefix_ = prefix.blank? ? '' : "#{prefix}_"
    translation_equivalent_prefix = "#{prefix_}translation_equivalent_#{self.id}"
    document["#{translation_equivalent_prefix}_content_s"] = self.content
    document["#{translation_equivalent_prefix}_language_s"] = self.language.name
    document["#{translation_equivalent_prefix}_language_code_s"] = self.language.code
    citation_references = self.citations.collect { |c| c.bibliographic_reference }
    document["#{translation_equivalent_prefix}_citation_references_ss"] = citation_references if !citation_references.blank?
  end
end
