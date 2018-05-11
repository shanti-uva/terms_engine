# == Schema Information
#
# Table name: subject_term_associations
#
#  id         :integer          not null, primary key
#  feature_id :integer          not null
#  subject_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  branch_id  :integer          not null
#

class PhonemeTermAssociation < SubjectTermAssociation
  default_scope { where(branch_id: 9310) }
end
