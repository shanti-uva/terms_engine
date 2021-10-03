# == Schema Information
#
# Table name: citation_association
#
#  id                     :bigint           not null, primary key
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  associated_citation_id :bigint
#  citation_id            :bigint
#
# Indexes
#
#  index_associated_citations_on_associated_citation_id  (associated_citation_id)
#  index_associated_citations_on_citation_id             (citation_id)
#
# Foreign Keys
#
#  fk_rails_...  (associated_citation_id => associated_citations.id)
#  fk_rails_...  (citation_id => citations.id)
#
class CitationAssociation < ApplicationRecord
  belongs_to :citation
  belongs_to :associated_citation, class_name: 'Citation'
  
  has_many :imports, as: 'item', dependent: :destroy
end
