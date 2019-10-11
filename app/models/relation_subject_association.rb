class RelationSubjectAssociation < ApplicationRecord

  belongs_to :feature_relation
  
  validates_presence_of :feature_relation_id
  validates_presence_of :subject_id
  validates_presence_of :branch_id
  
  def subject
    SubjectsIntegration::Feature.flare_search(self.subject_id)
  end
  
  def branch
    SubjectsIntegration::Feature.flare_search(self.branch_id)
  end
end
