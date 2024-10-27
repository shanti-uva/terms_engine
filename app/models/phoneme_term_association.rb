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

class PhonemeTermAssociation < SubjectTermAssociation
  default_scope { where(branch_id: PHONEME_BRANCH_IDS) }
end
