class Admin::DefinitionsController < AclController
  include KmapsEngine::ResourceObjectAuthentication
  resource_controller

  belongs_to :feature
  before_action :collection, :only=>:locate_for_relation

  new_action.before do
    @languages = Language.order('name')
    @authors = AuthenticatedSystem::Person.order('fullname')
  end

  edit.before do
    @languages = Language.order('name')
    @authors = AuthenticatedSystem::Person.order('fullname')
  end
  
  create.before do
    @languages = Language.order('name')
    @authors = AuthenticatedSystem::Person.order('fullname')
  end
  
  update.before do
    @languages = Language.order('name')
    @authors = AuthenticatedSystem::Person.order('fullname')
  end

  def update
    object.update(definition_params)
    author_ids = definition_params[:author_ids].blank? ? [] : definition_params[:author_ids]
    object.author_ids = author_ids
    redirect_to admin_feature_definition_path(object.feature,object)
  end

  # renders add_author.js.erb
  def add_author
    @authors = AuthenticatedSystem::Person.order('fullname')
  end

  def locate_for_relation
    @locating_relation=true # flag used in template
    # Remove the Feature that is currently looking for a relation
    # (shouldn't relate to itself)
    @collection = @collection.where(['id <> ?', object.id])
    render :action => 'index'
  end

  protected

  #
  # Override ResourceController collection method
  #
  def collection
    feature_id = nil
    if params[:feature_id]
      feature_id = params[:feature_id]
    elsif params[:id]
      feature_id = object.feature_id
    end
    if params[:filter].blank? && !feature_id.blank?
      search_results = parent_object.definitions
    elsif !params[:filter].blank?
      search_results = Definition.search(params[:filter])
      search_results = search_results.where(:feature_id => feature_id) if feature_id
    else
      search_results = []
    end
    @collection = search_results.empty? ? search_results : search_results.page(params[:page])
  end
  # Only allow a trusted parameter "white list" through.
  def definition_params
    params.require(:definition).permit(:feature_id, :is_public, :is_primary, :ancestor_ids, :position, :content, :language_id, :numerology, :tense, author_ids: [])
  end
end
