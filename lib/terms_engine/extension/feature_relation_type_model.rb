module TermsEngine
  module Extension
    module FeatureRelationTypeModel
      extend ActiveSupport::Concern

      included do
      end

      def branch
        SubjectsIntegration::Feature.flare_search(self.branch_id)
      end

    end
  end
end
