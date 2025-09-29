class Admin::PassagesController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  include KmapsEngine::ResourceObjectAuthentication
  resource_controller
  belongs_to :definition, :feature

  create.wants.html do
    if object.context.instance_of? Feature
       redirect_to admin_feature_url(object.context.fid, section: 'passages')
    else
      redirect_to polymorphic_url([:admin, object.context.feature, object.context], section: 'passages') 
    end
  end
  
  update.wants.html do
    if object.context.instance_of? Feature
       redirect_to admin_feature_url(object.context.fid, section: 'passages')
    else
      redirect_to polymorphic_url([:admin, object.context.feature, object.context], section: 'passages') 
    end
  end

  # admin_feature_path(feature.fid)  

  protected

  # Only allow a trusted parameter "white list" through.
  def passage_params
    params.require(:passage).permit(:context_id, :context_type, :content)
  end
  
end
