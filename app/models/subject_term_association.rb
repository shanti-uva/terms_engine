# == Schema Information
#
# Table name: subject_term_associations
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  branch_id  :integer          not null
#  feature_id :integer          not null
#  subject_id :integer          not null
#

class SubjectTermAssociation < ApplicationRecord
  extend KmapsEngine::HasTimespan
  include KmapsEngine::IsCitable
  extend IsDateable
  include KmapsEngine::IsNotable

  validates_presence_of :feature_id
  validates_presence_of :subject_id
  validates_presence_of :branch_id
  
  belongs_to :feature, touch: true
  has_many :imports, :as => 'item', :dependent => :destroy
  
  def subject
    SubjectsIntegration::Feature.search(self.subject_id)
  end
  
  def branch
    SubjectsIntegration::Feature.search(self.branch_id)
  end
end
