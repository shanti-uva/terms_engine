module TermsEngine
  module SitemapsControllerOverrides
    
    private
    
    def base_feature_scope
      super.joins(:phoneme_term_associations).where('phoneme_term_associations.subject_id' => [Feature::BOD_EXPRESSION_SUBJECT_ID, Feature::ENG_WORD_SUBJECT_ID, Feature::ENG_PHRASE_SUBJECT_ID, Feature::NEW_EXPRESSION_SUBJECT_ID, Feature::NEP_EXPRESSION_SUBJECT_ID])
    end
  end
end