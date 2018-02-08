module TermsEngine
  module Extension
    module FeatureModel
      extend ActiveSupport::Concern

      included do
        has_many :subject_term_associations, dependent: :destroy
      end
      
      def pid
        "T#{self.fid}"
      end
      
      module ClassMethods
      end
    end
  end
end
