class Admin::DefinitionAssociationsController < AclController
  resource_controller
  belongs_to :definition
  
  def initialize
    super
    @guest_perms = []
  end
  
  create.wants.html do
    redirect_to admin_feature_definition_url(parent_object.feature, object.definition)
  end
  
  update.wants.html do
    object.reload
    redirect_to admin_feature_definition_url(parent_object.feature, object.definition)
  end
  
  destroy.wants.html { redirect_to admin_feature_definition_url(parent_object.feature, parent_object) }
  
  # Only allow a trusted parameter "white list" through.
  def definition_association_params
    params.require(:definition_association).permit(:definition_id, :feature_relation_type_id, :perspective_id, :associated_id, :associated_type)
  end
  
  private
  
  def get_perspectives
    @perspectives = parent_object.affiliations_by_user(current_user, descendants: true).collect(&:perspective)
    @perspectives = Perspective.order(:name) if current_user.admin? || @perspectives.include?(nil)
  end
end
