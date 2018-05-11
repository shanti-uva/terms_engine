# == Schema Information
#
# Table name: definition_subject_associations
#
#  id            :integer          not null, primary key
#  definition_id :integer          not null
#  subject_id    :integer          not null
#  branch_id     :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'test_helper'

class DefinitionSubjectAssociationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
