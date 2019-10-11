module TermsEngine
  module Extension
    module AdminFeatureRelationsController
      extend ActiveSupport::Concern

      included do
        new_action.before do |c|
          c.send :setup_for_new_relation
          get_perspectives
          object.build_relation_subject_association(branch_id: ConjugationAssociation::BRANCH_ID)
        end

        edit.before do
          get_perspectives
          if object.relation_subject_association.nil?
            object.build_relation_subject_association(branch_id: ConjugationAssociation::BRANCH_ID)
          end
        end

        update do
          failure.wants.html do
            get_perspectives
            if object.relation_subject_association.nil?
              object.build_relation_subject_association(branch_id: ConjugationAssociation::BRANCH_ID)
            end
            render action: 'edit'
          end
        end

        update.after do
          if object.feature_relation_type.branch_id.blank? && object.relation_subject_association.id?
            if !object.relation_subject_association.subject['ancestor_ids_gen'].include?(object.feature_relation_type.branch_id)
              object.relation_subject_association.destroy!
            end
          end
        end
      end

      protected

      # Only allow a trusted parameter "white list" through.
      def feature_relation_params
        # check kmaps_engine, it swaps the child and parent depending on the relation type (Asymetric or not)
        process_feature_relation_type_id_mark

        if !params['feature_relation']['relation_subject_association_attributes'].nil? && params['feature_relation']['relation_subject_association_attributes']['subject_id'].blank?
          params['feature_relation'].delete('relation_subject_association_attributes')
        end

        params.require(:feature_relation).permit(:perspective_id, :parent_node_id, :child_node_id, :feature_relation_type_id, :ancestor_ids, :skip_update, relation_subject_association_attributes: [:id, :subject_id, :branch_id, :feature_relation_id])
      end
    end
  end
end
