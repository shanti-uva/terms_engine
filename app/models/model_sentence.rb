# == Schema Information
#
# Table name: model_sentences
#
#  id           :bigint(8)        not null, primary key
#  context_id   :integer          not null
#  context_type :string           not null
#  content      :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class ModelSentence < ApplicationRecord
  belongs_to :context, polymorphic: true

  validates_presence_of :content
end
