class Admin::PassageTranslationsController < AclController
  include KmapsEngine::ResourceObjectAuthentication
  resource_controller

  belongs_to :definition, :passage

  new_action.before do
    @languages = Language.order('name')
  end

  edit.before do
    @languages = Language.order('name')
  end

  protected

  # Only allow a trusted parameter "white list" through.
  def passage_translation_params
    params.require(:passage_translation).permit(:context_id, :context_type, :content)
  end
  
end

