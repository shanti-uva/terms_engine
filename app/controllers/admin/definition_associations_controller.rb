class Admin::DefinitionAssociationsController < ApplicationController
  resource_controller
  belongs_to :definition
  
  create.wants.html do
    redirect_to admin_feature_definition_url(parent_object.feature, object.definition)
  end
  
  update.wants.html do
    object.reload
    redirect_to admin_feature_definition_url(parent_object.feature, object.definition)
  end
  
  destroy.wants.html { redirect_to admin_feature_definition_url(parent_object.feature, parent_object) }
  
  protected
  
  # Only allow a trusted parameter "white list" through.
  def definition_association_params
    params.require(:definition_association).permit(:definition_id, :feature_relation_type_id, :perspective_id, :associated_id, :associated_type)
  end
end
