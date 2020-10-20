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
      
      # POST /feature_relations
      def create
        term_str = Feature.model_name.to_s
        definition_str = Definition.model_name.to_s
        relation_params = params.require(:feature_relation).permit(:perspective_id, :parent_node_id, :child_node_id, :feature_relation_type_id)
        relation_source = params['relation_source']
        relation_dest = params['relation_dest']
        if relation_source==term_str && relation_dest==term_str
          feature_relation = FeatureRelation.new(relation_params)
          if feature_relation.save
            redirect_to(admin_feature_feature_relation_url(feature_relation.child_node, feature_relation), notice: 'Feature relation was successfully created.')
          else
            redirect_to(new_admin_feature_feature_relation_url(feature_relation.child_node, target_id: feature_relation.parent_node))
          end
        else
          definition_association = DefinitionAssociation.new(perspective_id: relation_params[:perspective_id], feature_relation_type_id: relation_params[:feature_relation_type_id])
          if relation_source==term_str #relation_dest has to be definition, else it wouldn't have made it to the else
            definition_association.definition_id = params['dest_definition_id']
            definition_association.associated_type = relation_source
            definition_association.associated_id = relation_params[:child_node_id]
            dest_url = admin_feature_feature_relations_url(definition_association.associated)
          else #relation_source is definition, relation_dest may be definition or term
            definition_association.definition_id = params['source_definition_id']
            definition_association.associated_type = relation_dest
            definition_association.associated_id = relation_dest==term_str ? relation_params[:parent_node_id] : params['dest_definition_id']
          end
          if definition_association.save
            dest_url ||= admin_definition_definition_association_url(definition_association.definition, definition_association)
            redirect_to(dest_url, notice: 'Feature relation was successfully created.')
          else
            redirect_to(admin_feature_definition_url(definition_association.definition.feature, definition_association.definition))
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
