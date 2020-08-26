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
class ConjugationAssociation < RelationSubjectAssociation

  BRANCH_ID=1787

  default_scope { where(branch_id: BRANCH_ID) }

end
