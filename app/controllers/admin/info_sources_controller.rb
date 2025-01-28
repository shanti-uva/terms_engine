class Admin::InfoSourcesController < AclController
  resource_controller
  
  caches_page :index, if: Proc.new { |c| c.request.format.xml? || c.request.format.json? }
  cache_sweeper :info_source_sweeper, only: [:update, :destroy]
  
  def initialize
    super
    @guest_perms = ['admin/info_sources/index']
  end
  
  def collection
    @collection = InfoSource.search(params[:filter]).order(:position).page(params[:page])
  end
  
  def prioritize
    @info_sources = InfoSource.all.order(:position)
  end
  
  def set_priorities
    InfoSource.all.each do |info_source|
      info_source.position = params[:info_source].index(info_source.id.to_s) + 1
      info_source.save if info_source.position_changed?
    end
    render plain: ''
  end
  
  index.wants.xml { render xml: JSON.parse(@collection.to_json).to_xml(root: :info_sources) }
  index.wants.json { render json: @collection }
  
  protected
  
  # Only allow a trusted parameter "white list" through.
  def info_source_params
    params.require(:info_source).permit(:code, :title, :agent, :language_id, :date_published)
  end
end