module TermsEngine
  module NotesControllerExtensions
    extend ActiveSupport::Concern

    included do
      belongs_to :definition, :description, :etymology, :feature_geo_code, :feature_name, :feature_name_relation, :feature_relation, :non_phoneme_term_association, :passage, :passage_translation, :time_unit, :translation_equivalent
    end
  end
end