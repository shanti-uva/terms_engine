module TermsEngine
  module Extension
    module FeatureModel
      extend ActiveSupport::Concern

      included do
      end
      
      def pid
        "T#{self.fid}"
      end
      
      module ClassMethods
      end
    end
  end
end
