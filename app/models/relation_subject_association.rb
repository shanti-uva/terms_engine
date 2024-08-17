# == Schema Information
#
# Table name: relation_subject_associations
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  branch_id           :integer          not null
#  feature_relation_id :bigint           not null
#  subject_id          :integer          not null
#
# Indexes
#
#  index_relation_subject_associations_on_feature_relation_id  (feature_relation_id)
#
# Foreign Keys
#
#  fk_rails_...  (feature_relation_id => feature_relations.id)
#
class RelationSubjectAssociation < ApplicationRecord

  belongs_to :feature_relation, touch: true
  # Had to comment this out for nested attributes from form to not break.
  #validates_presence_of :feature_relation_id
  validates_presence_of :subject_id
  validates_presence_of :branch_id
  
  def subject
    SubjectsIntegration::Feature.search(self.subject_id)
  end
  
  def branch
    SubjectsIntegration::Feature.search(self.branch_id)
  end
  
  def feature
    self.feature_relation.feature
  end
end
