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

class NonPhonemeTermAssociation < SubjectTermAssociation
  PHONEME_BRANCH_IDS = [Feature::BOD_PHONEME_SUBJECT_ID, Feature::ENG_PHONEME_SUBJECT_ID, Feature::NEW_PHONEME_SUBJECT_ID]
  default_scope { where.not(branch_id: PHONEME_BRANCH_IDS) }
end
