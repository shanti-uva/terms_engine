class Admin::InfoSourcesController < AclController
  resource_controller
  
  def initialize
    super
    @guest_perms = []
  end
  
  def collection
    @collection = InfoSource.search(params[:filter]).page(params[:page])
  end
    
  protected
  
  # Only allow a trusted parameter "white list" through.
  def info_source_params
    params.require(:info_source).permit(:code, :title, :agent, :date_published)
  end
end