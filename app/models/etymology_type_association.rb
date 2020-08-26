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

class EtymologyTypeAssociation < EtymologySubjectAssociation

  BRANCH_ID=182

  default_scope { where(branch_id: BRANCH_ID) }

end
