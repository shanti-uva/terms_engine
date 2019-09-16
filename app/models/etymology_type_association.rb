# == Schema Information
#
# Table name: etymology_subject_associations
#
#  id           :bigint(8)        not null, primary key
#  etymology_id :bigint(8)        not null
#  subject_id   :integer          not null
#  branch_id    :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class EtymologyTypeAssociation < EtymologySubjectAssociation

  BRANCH_ID=182

  default_scope { where(branch_id: BRANCH_ID) }

end
