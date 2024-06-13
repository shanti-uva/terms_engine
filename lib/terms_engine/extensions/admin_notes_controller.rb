module TermsEngine
  module Extension
    module AdminNotesController

      extend ActiveSupport::Concern

      included do
        belongs_to :description, :feature_geo_code, :feature_name, :feature_name_relation, :feature_relation, :time_unit, # from kmaps_engine
        :definition, :etymology, :passage, :passage_translation, :subject_term_association #specific to terms_engine

       
        create.wants.html  { redirect_to polymorphic_url(helpers.stacked_parents, section: 'notes') }
        update.wants.html  { redirect_to polymorphic_url(helpers.stacked_parents, section: 'notes') }
        destroy.wants.html { redirect_to polymorphic_url(helpers.stacked_parents, section: 'notes') }

      end
      
    end
  end
end
