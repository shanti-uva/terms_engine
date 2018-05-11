# == Schema Information
#
# Table name: definition_subject_associations
#
#  id            :integer          not null, primary key
#  definition_id :integer          not null
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
end
