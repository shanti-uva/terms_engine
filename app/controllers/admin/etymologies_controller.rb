class Admin::EtymologiesController < AclController
  include KmapsEngine::ResourceObjectAuthentication
  resource_controller

  belongs_to :definition, :feature

  new_action.before do
    object.build_etymology_type_association
  end

  edit.before do
    if object.etymology_type_association.nil?
      object.build_etymology_type_association
    end
  end

  create.after do
    object.create_etymology_type_association(etymology_type_association_params[:etymology_type_association_attributes])
    if !object.valid?
      object.destroy!
      @object = Etymology.new(etymology_params)
      object.build_etymology_type_association(etymology_type_association_params[:etymology_type_association_attributes])
    end
  end
  
  create do
    wants.html { redirect_to(polymorphic_url([:admin, object.context, object])) }
    failure.wants.html do
      flash[:notice] = 'Etymology type associations failed to save.'
      render :new
    end
  end

  protected

  # Only allow a trusted parameter "white list" through.
  def etymology_params
    params.require(:etymology).permit(:context_id, :context_type, :feature_id, :content)
  end
  
  def etymology_type_association_params
    params.require(:etymology).permit(etymology_type_association_attributes: [:id, :subject_id, :branch_id, :etymology_id])
  end
end
