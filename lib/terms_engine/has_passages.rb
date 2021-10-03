module KmapsEngine
  module HasPassages
    extend ActiveSupport::Concern

    included do
      has_many :passages, as: :context, dependent: :destroy
    end
  end
end
