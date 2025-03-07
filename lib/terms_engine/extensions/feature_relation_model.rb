module TermsEngine
  module Extension
    module FeatureRelationModel
      extend ActiveSupport::Concern

      included do
        has_one :relation_subject_association, dependent: :destroy
        has_many :legacy_citations, -> { where(info_source_type: InfoSource.model_name.name) }, as: :citable, class_name: 'Citation'
        has_many :standard_citations, -> { where.not(info_source_type: InfoSource.model_name.name) }, as: :citable, class_name: 'Citation'
        
        accepts_nested_attributes_for :relation_subject_association
      end
      
    end
  end
end
