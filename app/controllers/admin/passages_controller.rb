class Admin::PassagesController < AclController
  include KmapsEngine::ResourceObjectAuthentication
  resource_controller

  belongs_to :definition, :feature

  create.wants.html { redirect_to admin_feature_path(object.feature_id, section: "passages") } 
  update.wants.html { redirect_to admin_feature_path(object.feature_id, section: "passages") } 

  protected

  # Only allow a trusted parameter "white list" through.
  def passage_params
    params.require(:passage).permit(:context_id, :context_type, :content)
  end
  
end
