# == Schema Information
#
# Table name: definition_relations
#
#  id             :integer          not null, primary key
#  child_node_id  :integer          not null
#  parent_node_id :integer          not null
#  ancestor_ids   :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class DefinitionRelationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
