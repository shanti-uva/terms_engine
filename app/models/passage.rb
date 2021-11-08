# == Schema Information
#
# Table name: passages
#
#  id           :bigint           not null, primary key
#  content      :text             not null
#  context_type :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  context_id   :integer          not null
#

class Passage < ApplicationRecord
  include KmapsEngine::IsCitable
  include KmapsEngine::IsNotable
  
  belongs_to :context, polymorphic: true, touch: true
  has_many :passage_translations, as: :context, dependent: :destroy
  
  validates_presence_of :content
  
  def feature
    self.context.feature
  end
  
  def rsolr_document_tags(document, prefix = '')
    prefix_ = prefix.blank? ? '' : "#{prefix}_"
    passage_prefix = "#{prefix_}passage_#{self.id}"
    document["#{passage_prefix}_content_s"] = self.content
    self.passage_translations.each { |pt| pt.rsolr_document_tags(document, passage_prefix) }
    citation_references = self.citations.collect { |c| c.bibliographic_reference }
    document["#{passage_prefix}_citation_references_ss"] = citation_references if !citation_references.blank?
    self.notes.each { |n| n.rsolr_document_tags(document, passage_prefix) }
  end
end
