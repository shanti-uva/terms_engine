module TermsEngine
  module Extension
    module AdminCitationsController
      extend ActiveSupport::Concern

      included do
        belongs_to :caption, :description, :feature, :feature_geo_code, :feature_name, :feature_name_relation, :feature_relation, :summary, #This list comes from the CitationsController in kmaps_engine
        :definition, :passage, :subject_term_association #specific to terms_engine

        create.wants.html  { redirect_to polymorphic_url(helpers.stacked_parents, section: 'citations') }
        update.wants.html  { redirect_to polymorphic_url(helpers.stacked_parents, section: 'citations') }
        destroy.wants.html { redirect_to polymorphic_url(helpers.stacked_parents, section: 'citations') }

      end
      
    end
  end
end
