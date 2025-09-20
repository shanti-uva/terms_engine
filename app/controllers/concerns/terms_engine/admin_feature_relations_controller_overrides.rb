module TermsEngine
  module AdminFeatureRelationsControllerOverrides
    protected
    
    def get_perspectives
      @perspectives = parent_object.affiliations_by_user(current_user, descendants: true).collect(&:perspective).reject(&:is_public)
      @perspectives = Perspective.where(is_public: false).order(:name) if current_user.admin? || @perspectives.blank?
    end

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