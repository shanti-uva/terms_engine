module TermsEngine
  module Extension
    module CitationsController
      extend ActiveSupport::Concern

      included do
        # This is an extension of the END USER citations display. Make sure there are the corresponding routes, controllers and views.
        belongs_to :description, :feature_geo_code, :feature_name, :feature_name_relation, :feature_relation, #This list comes from the CitationsController in kmaps_engine
        :definition, :definition_association, :etymology, :non_phoneme_term_association, :passage, :passage_translation, :translation_equivalent #specific to terms_engine
      end
      
      def collection
        @collection ||= parent_object.citations.where.not(info_source_type: :InfoSource)
      end
    end
  end
end
