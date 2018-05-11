# == Schema Information
#
# Table name: subject_term_associations
#
#  id         :integer          not null, primary key
#  feature_id :integer          not null
#  subject_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  branch_id  :integer          not null
#

class SubjectTermAssociation < ApplicationRecord
  belongs_to :feature
  
  extend KmapsEngine::HasTimespan
  include KmapsEngine::IsCitable
  extend IsDateable
  include KmapsEngine::IsNotable

  validates_presence_of :feature_id
  validates_presence_of :subject_id
  validates_presence_of :branch_id
  
  def subject
    SubjectsIntegration::Feature.flare_search(self.subject_id)
  end
end
