# == Schema Information
#
# Table name: translation_equivalents
#
#  id          :bigint           not null, primary key
#  content     :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  feature_id  :bigint           not null
#  language_id :integer          not null
#
# Indexes
#
#  index_translation_equivalents_on_feature_id  (feature_id)
#
# Foreign Keys
#
#  fk_rails_...  (feature_id => features.id)
#
require 'rails_helper'

RSpec.describe TranslationEquivalent, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
