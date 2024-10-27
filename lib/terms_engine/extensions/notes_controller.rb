module TermsEngine
  module Extension
    module NotesController
      extend ActiveSupport::Concern

      included do
        belongs_to :definition, :description, :feature_geo_code, :feature_name, :feature_name_relation, :feature_relation, :time_unit
      end
    end
  end
end