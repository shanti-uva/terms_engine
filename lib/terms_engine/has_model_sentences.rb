module TermsEngine
  module HasModelSentences
    extend ActiveSupport::Concern

    included do
      has_many :model_sentences, as: :context, dependent: :destroy
    end
  end
end
