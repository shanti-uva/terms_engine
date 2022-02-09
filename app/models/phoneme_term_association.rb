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
  default_scope { where(branch_id: [Feature::BOD_PHONEME_SUBJECT_ID, Feature::ENG_PHONEME_SUBJECT_ID]) }
end
