# == Schema Information
#
# Table name: model_sentences
#
#  id           :bigint           not null, primary key
#  content      :text             not null
#  context_type :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  context_id   :integer          not null
#

class ModelSentence < ApplicationRecord
  belongs_to :context, polymorphic: true, touch: true
  has_many :imports, as: 'item', dependent: :destroy
  has_many :translations, class_name: 'SentenceTranslation', dependent: :destroy

  validates_presence_of :content
  
  def feature
    self.context.feature
  end
end
