module TermsEngine
  module Extension
    module FeatureRelationTypeModel
      extend ActiveSupport::Concern

      included do
      end

      def branch
        SubjectsIntegration::Feature.search(self.branch_id)
      end

    end
  end
end
