# == Schema Information
#
# Table name: translation_equivalents
#
#  id           :bigint           not null, primary key
#  content      :string
#  context_type :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  context_id   :bigint
#  language_id  :integer          not null
#
# Indexes
#
#  index_translation_equivalents_on_context_type_and_context_id  (context_type,context_id)
#
require 'rails_helper'

RSpec.describe TranslationEquivalent, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
