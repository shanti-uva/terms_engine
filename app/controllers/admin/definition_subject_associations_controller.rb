class Admin::DefinitionSubjectAssociationsController < AclController
  include KmapsEngine::ResourceObjectAuthentication
  resource_controller

  belongs_to :definition

  new_action.before { object.branch_id = params[:branch_id] if params[:branch_id] }

  destroy.wants.html { redirect_to admin_feature_definition_path(object.definition.feature,object.definition) }

  protected

  # Only allow a trusted parameter "white list" through.
  def definition_subject_association_params
    params.require(:definition_subject_association).permit(:definition_id, :subject_id, :branch_id)
  end
end
