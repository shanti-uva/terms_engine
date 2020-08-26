# == Schema Information
#
# Table name: etymology_subject_associations
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  branch_id    :integer          not null
#  etymology_id :bigint           not null
#  subject_id   :integer          not null
#
# Indexes
#
#  index_etymology_subject_associations_on_etymology_id  (etymology_id)
#
# Foreign Keys
#
#  fk_rails_...  (etymology_id => etymologies.id)
#

class EtymologySubjectAssociation < ApplicationRecord
  belongs_to :etymology
  
  validates_presence_of :etymology_id
  validates_presence_of :subject_id
  validates_presence_of :branch_id
  
  def subject
    SubjectsIntegration::Feature.flare_search(self.subject_id)
  end
  
  def branch
    SubjectsIntegration::Feature.flare_search(self.branch_id)
  end
end
