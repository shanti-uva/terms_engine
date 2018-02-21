module TermsEngine
  module Extension
    module FeatureModel
      extend ActiveSupport::Concern

      included do
        has_many :subject_term_associations, dependent: :destroy
        
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
      
      module ClassMethods
      end
    end
  end
end
