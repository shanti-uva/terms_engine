# == Schema Information
#
# Table name: definitions
#
#  id           :integer          not null, primary key
#  feature_id   :integer          not null
#  language_id  :integer          not null
#  is_public    :boolean          default(FALSE), not null
#  is_primary   :boolean
#  ancestor_ids :string
#  position     :integer          default(0)
#  content      :text             not null
#  author_id    :integer
#  numerology   :integer
#  tense        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'test_helper'

class DefinitionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
