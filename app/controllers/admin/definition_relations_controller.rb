class Admin::DefinitionRelationsController < AclController
  before_action :set_definition_relation, only: [:show, :edit, :update, :destroy]

  # GET /definition_relations
  def index
    @definition_relations = DefinitionRelation.all
  end

  # GET /definition_relations/1
  def show
  end

  # GET /definition_relations/new
  def new
    @definition_relation = DefinitionRelation.new
  end

  # GET /definition_relations/1/edit
  def edit
  end

  # POST /definition_relations
  def create
    @definition_relation = DefinitionRelation.new(definition_relation_params)

    if @definition_relation.save
      redirect_to @definition_relation, notice: 'Definition relation was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /definition_relations/1
  def update
    if @definition_relation.update(definition_relation_params)
      redirect_to @definition_relation, notice: 'Definition relation was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /definition_relations/1
  def destroy
    @definition_relation.destroy
    redirect_to definition_relations_url, notice: 'Definition relation was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_definition_relation
      @definition_relation = DefinitionRelation.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def definition_relation_params
      params.require(:definition_relation).permit(:child_node_id, :parent_node_id, :ancestor_ids)
    end
end
