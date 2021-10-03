module TermsEngine
  module Extension
    module CitationsController
      extend ActiveSupport::Concern

      included do
        # This is an extension of the END USER citations display. Make sure there are the corresponding routes, controllers and views.
        belongs_to :descriptions, :feature_geo_code, :feature_name, :feature_name_relation, :feature_relation, #This list comes from the CitationsController in kmaps_engine
        :passage, :passage_translation, :definition_association #specific to places_engine
      end
    end
  end
end
