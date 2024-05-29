# == Schema Information
#
# Table name: passage_translations
#
#  id           :bigint           not null, primary key
#  content      :text             not null
#  context_type :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  context_id   :bigint           not null
#  language_id  :integer          not null
# 
# Indexes
#
#  index_passage_translations_on_context_type_and_context_id  (context_type,context_id)
#
class PassageTranslation < ApplicationRecord
  include KmapsEngine::IsCitable
  include KmapsEngine::IsNotable
  
  belongs_to :context, polymorphic: true, touch: true
  belongs_to :language
  
  def feature
    self.context.feature
  end
  
  def rsolr_document_tags(document, prefix = '')
    prefix_ = prefix.blank? ? '' : "#{prefix}_"
    passage_translation_prefix = "#{prefix_}passage_translation_#{self.id}"
    document["#{passage_translation_prefix}_content_t"] = self.content
    document["#{passage_translation_prefix}_language_s"] = self.language.name
    document["#{passage_translation_prefix}_language_code_s"] = self.language.code
    citation_references = self.citations.collect { |c| c.bibliographic_reference }
    document["#{passage_translation_prefix}_citation_references_ss"] = citation_references if !citation_references.blank?
    self.notes.each { |n| n.rsolr_document_tags(document, passage_translation_prefix) }
  end

end
