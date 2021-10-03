# == Schema Information
#
# Table name: citation_associations
#
#  id                     :bigint           not null, primary key
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  associated_id :bigint
#  citation_id            :bigint
#
# Indexes
#
#  index_citation_associations_on_associated_citation_id  (associated_citation_id)
#  index_citation_associations_on_citation_id             (citation_id)
#
# Foreign Keys
#
#  fk_rails_...  (associated_citation_id => citations.id)
#  fk_rails_...  (citation_id => citations.id)
#
require 'rails_helper'

RSpec.describe CitationAssociation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
