# == Schema Information
#
# Table name: passage_translations
#
#  id           :bigint           not null, primary key
#  content      :text             not null
#  context_type :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  context_id   :bigint           not null
#  language_id  :integer          not null
#
# Indexes
#
#  index_passage_translations_on_context_type_and_context_id  (context_type,context_id)
#
require 'rails_helper'

RSpec.describe PassageTranslation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
