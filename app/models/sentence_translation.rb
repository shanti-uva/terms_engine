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
class SentenceTranslation < ApplicationRecord
  belongs_to :model_sentence
  belongs_to :language
  has_many :imports, as: 'item', dependent: :destroy
end
