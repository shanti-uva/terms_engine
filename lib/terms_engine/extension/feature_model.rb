module TermsEngine
  module Extension
    module FeatureModel
      extend ActiveSupport::Concern

      included do
        PHONEME_SUBJECT_ID = 9310
        LETTER_SUBJECT_ID = 9311
        NAME_SUBJECT_ID = 9312
        PHRASE_SUBJECT_ID = 9314
        EXPRESSION_SUBJECT_ID = 9315
        
        has_many :subject_term_associations, dependent: :destroy
        has_many :phoneme_term_associations
        
        # This fetches root *Definitions* (definitions that don't have parents),
        # within the scope of the current feature
        has_many :definitions, dependent: :destroy do
          #
          #
          #
          def roots
            # proxy_target, proxy_owner, proxy_reflection - See Rails "Association Extensions"
            pa = proxy_association
            pa.reflection.class_name.constantize.roots.where('definitions.feature_id' => pa.owner.id).order(:position) #.sort !!! See the FeatureName.<=> method
          end
        end
      end
      
      def pid
        "T#{self.fid}"
      end
      
      def phonemes
        self.phoneme_term_associations.collect(&:subject)
      end
      
      module ClassMethods
        
        def search_by_phoneme(name, phoneme_id)
          names = FeatureName.where(name: name).includes(feature: :subject_term_associations)
          name_position = names.find_index{ |n| n.feature.subject_term_associations.collect(&:subject_id).include? phoneme_id }
          name_position.nil? ? nil : names[name_position].feature
        end
        
        def search_expression(name)
          Feature.search_by_phoneme(name, EXPRESSION_SUBJECT_ID)
        end
      end
    end
  end
end
