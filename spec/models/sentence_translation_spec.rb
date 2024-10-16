# == Schema Information
#
# Table name: sentence_translations
#
#  id                :bigint           not null, primary key
#  content           :text             not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  language_id       :integer          not null
#  model_sentence_id :bigint           not null
#
# Indexes
#
#  index_sentence_translations_on_model_sentence_id  (model_sentence_id)
#
# Foreign Keys
#
#  fk_rails_...  (model_sentence_id => model_sentences.id)
#
require 'rails_helper'

RSpec.describe SentenceTranslation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
