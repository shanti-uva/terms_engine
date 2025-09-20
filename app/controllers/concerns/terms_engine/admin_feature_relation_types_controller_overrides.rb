module TermsEngine
  module AdminFeatureRelationTypesControllerOverrides
    protected

    # Only allow a trusted parameter "white list" through.
    def feature_relation_type_params
      params.require(:feature_relation_type).permit(:is_hierarchical, :is_symmetric, :label, :asymmetric_label, :code, :asymmetric_code, :branch_id)
    end
  end
end
