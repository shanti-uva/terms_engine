# == Schema Information
#
# Table name: definition_subject_associations
#
#  id            :bigint(8)        not null, primary key
#  definition_id :bigint(8)        not null
#  subject_id    :integer          not null
#  branch_id     :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class DefinitionSubjectAssociation < ApplicationRecord
  belongs_to :definition
  
  validates_presence_of :definition_id
  validates_presence_of :subject_id
  validates_presence_of :branch_id
  
  def subject
    SubjectsIntegration::Feature.flare_search(self.subject_id)
  end
  
  def branch
    SubjectsIntegration::Feature.flare_search(self.branch_id)
  end
end
