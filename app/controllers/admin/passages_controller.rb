class Admin::PassagesController < AclController
  include KmapsEngine::ResourceObjectAuthentication
  resource_controller

  belongs_to :definition, :feature

  protected

  # Only allow a trusted parameter "white list" through.
  def passage_params
    params.require(:passage).permit(:context_id, :context_type, :content)
  end
  
end
