class Admin::DefinitionsController < AclController
  before_action :set_definition, only: [:show, :edit, :update, :destroy]

  # GET /definitions
  def index
    @definitions = Definition.all
  end

  # GET /definitions/1
  def show
  end

  # GET /definitions/new
  def new
    @definition = Definition.new
  end

  # GET /definitions/1/edit
  def edit
  end

  # POST /definitions
  def create
    @definition = Definition.new(definition_params)

    if @definition.save
      redirect_to @definition, notice: 'Definition was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /definitions/1
  def update
    if @definition.update(definition_params)
      redirect_to @definition, notice: 'Definition was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /definitions/1
  def destroy
    @definition.destroy
    redirect_to definitions_url, notice: 'Definition was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_definition
      @definition = Definition.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def definition_params
      params.require(:definition).permit(:feature_id, :is_public, :is_primary, :ancestor_ids, :position, :content, :author_id, :numerology, :tense)
    end
end
