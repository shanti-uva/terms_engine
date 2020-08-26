# == Schema Information
#
# Table name: definition_subject_associations
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  branch_id     :integer          not null
#  definition_id :bigint           not null
#  subject_id    :integer          not null
#
# Indexes
#
#  index_definition_subject_associations_on_definition_id  (definition_id)
#
# Foreign Keys
#
#  fk_rails_...  (definition_id => definitions.id)
#

class DefinitionSubjectAssociation < ApplicationRecord
  validates_presence_of :definition_id
  validates_presence_of :subject_id
  validates_presence_of :branch_id
  
  belongs_to :definition
  has_many :imports, :as => 'item', :dependent => :destroy
  
  def subject
    SubjectsIntegration::Feature.flare_search(self.subject_id)
  end
  
  def branch
    SubjectsIntegration::Feature.flare_search(self.branch_id)
  end
end
