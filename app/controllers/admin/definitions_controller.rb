class Admin::DefinitionsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  include KmapsEngine::ResourceObjectAuthentication
  resource_controller
  belongs_to :feature
  before_action :collection, :only=>:locate_for_relation

  create.wants.html { redirect_to admin_feature_url(object.feature.fid, section: 'definitions') }
  update.wants.html { redirect_to admin_feature_url(object.feature.fid, section: 'definitions') }

  new_action.before do
    @languages = Language.order('name')
    @authors = AuthenticatedSystem::Person.order('fullname')
    @enumeration = object.build_enumeration
  end

  edit.before do
    @languages = Language.order('name')
    @authors = AuthenticatedSystem::Person.order('fullname')
    @enumeration = object.enumeration.nil? ? object.build_enumeration : object.enumeration
  end
  
  create.before do
    @languages = Language.order('name')
    @authors = AuthenticatedSystem::Person.order('fullname')
  end

  create.after do
    Enumeration.create(value: params[:enumeration][:value], context_type: 'Definition', context_id: object.id) unless params[:enumeration][:value].blank?
  end
  
  update.before do
    @languages = Language.order('name')
    @authors = AuthenticatedSystem::Person.order('fullname')
  end

  update.after do
    e = Enumeration.where(context_id: object.id, context_type: 'Definition').last
    if e.nil?
      Enumeration.create(value: params[:enumeration][:value], context_type: 'Definition', context_id: object.id)
    else
      if params[:enumeration][:value].blank?
        e.destroy
      else
        e.update_attribute(:value, params[:enumeration][:value])
      end
    end
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
  
  def definition_params
    params.require(:definition).permit(:feature_id, :is_public, :is_primary, :ancestor_ids, :position, :content, :author_id, :language_id, :tense)
  end

  def enumeration_params
    params.require(:enumeration).permit(:value, :context_id)
  end
  
end
