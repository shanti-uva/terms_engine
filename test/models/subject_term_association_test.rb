# == Schema Information
#
# Table name: subject_term_associations
#
#  id         :integer          not null, primary key
#  feature_id :integer          not null
#  subject_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class SubjectTermAssociationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
