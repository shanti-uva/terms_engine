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

  create.before do
    @languages = Language.order('name')
  end

  create.wants.html do
    if object.context.instance_of? Definition
      redirect_to polymorphic_url( [:admin, object.context.feature, object.context], section: 'passage_translations' )
    else
      redirect_to polymorphic_url( [:admin, object.context], section: 'passage_translations' )
    end
  end
  update.wants.html do
    if object.context.instance_of? Definition
      redirect_to polymorphic_url( [:admin, object.context.feature, object.context], section: 'passage_translations' )
    else
      redirect_to polymorphic_url( [:admin, object.context], section: 'passage_translations' )
    end
  end
  destroy.wants.html do
    if object.context.instance_of? Definition
      redirect_to polymorphic_url( [:admin, object.context.feature, object.context], section: 'passage_translations' )
    else
      redirect_to polymorphic_url( [:admin, object.context], section: 'passage_translations' )
    end
  end

  protected

  # Only allow a trusted parameter "white list" through.
  def passage_translation_params
    params.require(:passage_translation).permit(:context_id, :context_type, :content, :language_id)
  end
  
end

