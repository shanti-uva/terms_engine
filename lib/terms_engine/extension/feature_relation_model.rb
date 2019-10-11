module TermsEngine
  module Extension
    module FeatureRelationModel
      extend ActiveSupport::Concern

      included do
        has_one :relation_subject_association, dependent: :destroy

        accepts_nested_attributes_for :relation_subject_association
      end
      
    end
  end
end
