class Admin::DefinitionRelationsController < AclController
  include KmapsEngine::ResourceObjectAuthentication
  resource_controller

  belongs_to :definition
  before_action :set_definition_relation, only: [:show, :edit, :update, :destroy]


  new_action.before do
    object.parent_node_id = params[:target_id]
    object.child_node_id = params[:definition_id]
  end

  protected
    # Use callbacks to share common setup or constraints between actions.
    def set_definition_relation
      @definition_relation = DefinitionRelation.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def definition_relation_params
      params.require(:definition_relation).permit(:child_node_id, :parent_node_id, :ancestor_ids)
    end

  private
  #
  # Needed to view (example)
  # /admin/definitions/1057/definition_relations/22
  # This is called by ResourceController!
  #
  def parent_association
    ## Gotta find (as in another SQL query) it seperately, will get a recursive stack error elsewise

    # If we're viewing a DefinitionRelation:
    return parent_object.parent_relations if params[:id].nil?

    # Gotta find it seperately (new query), will get a recursive stack error elsewise, rats!
    o = DefinitionRelation.find(params[:id])
    parent_object.id == o.parent_node.id ? parent_object.child_relations : parent_object.parent_relations
  end

  def collection
    definition_id = params[:definition_id]
    search_results = DefinitionRelation.search(params[:filter])
    search_results = search_results.where(['child_node_id = ?', definition_id]) if definition_id
    @collection = search_results.page(params[:page])
  end

end
