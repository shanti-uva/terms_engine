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

  PHONEME_BRANCH_IDS = [Feature::BOD_PHONEME_SUBJECT_ID, Feature::ENG_PHONEME_SUBJECT_ID, Feature::NEW_PHONEME_SUBJECT_ID]
  LANGUAGE_DETAIL_SUBJECTS = [184, 185, 301, 186, 5809, 187, 10358, 190, 286, 119]
  EXTRA_HIDDEN_SUBJECS     = [638, 9310, 9666, 10522]
  
  def subject
    SubjectsIntegration::Feature.search(self.subject_id)
  end
  
  def branch
    SubjectsIntegration::Feature.search(self.branch_id)
  end
end
