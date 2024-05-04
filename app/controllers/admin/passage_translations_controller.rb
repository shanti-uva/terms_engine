class Admin::PassageTranslationsController < AclController
  include KmapsEngine::ResourceObjectAuthentication
  resource_controller

  belongs_to :definition, :passage

  protected

  # Only allow a trusted parameter "white list" through.
  def passage_translation_params
    params.require(:passage_translation).permit(:context_id, :context_type, :content)
  end
  
end

