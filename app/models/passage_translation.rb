# == Schema Information
#
# Table name: passage_translations
#
#  id           :bigint           not null, primary key
#  content      :text
#  context_type :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  context_id   :bigint
#  language_id  :integer          not null
#
# Indexes
#
#  index_passage_translations_on_context_type_and_context_id  (context_type,context_id)
#
class PassageTranslation < ApplicationRecord
  include KmapsEngine::IsCitable
  include KmapsEngine::IsNotable
  
  belongs_to :context, polymorphic: true
  belongs_to :language
end
