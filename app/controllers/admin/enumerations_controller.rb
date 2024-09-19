class Admin::EnumerationsController < AclController

  include KmapsEngine::ResourceObjectAuthentication
  resource_controller

  belongs_to :definition, :feature

  create.wants.html do
    if object.context.instance_of? Feature
       redirect_to admin_feature_url(object.context.fid, section: 'definitions')
    else
      redirect_to polymorphic_url([:admin, object.context.feature, object.context], section: 'definitions') 
    end
  end
  update.wants.html do
    if object.context.instance_of? Feature
       redirect_to admin_feature_url(object.context.fid, section: 'definitions')
    else
      redirect_to admin_feature_definition_path(object.feature, object)
      #redirect_to polymorphic_url([:admin, object.context.feature, object.context], section: 'definitions') 
    end
  end

  protected

  def enumeration_params
    params.require(:enumerations).permit(:context_id, :context_type, :value)
  end
  
end