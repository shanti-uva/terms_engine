class Admin::EtymologiesController < AclController
  include KmapsEngine::ResourceObjectAuthentication
  resource_controller

  belongs_to :definition, :feature

  create.wants.html { redirect_to admin_feature_path(object.feature_id, section: "etymologies") } 
  update.wants.html { redirect_to admin_feature_path(object.feature_id, section: "etymologies") }

  new_action.before do
    object.build_etymology_type_association
  end

  edit.before do
    if object.etymology_type_association.nil?
      object.build_etymology_type_association
    end
  end

  create.after do
    association_params = etymology_type_association_params[:etymology_type_association_attributes]
    originally_valid = object.valid?
    if !association_params['subject_id'].blank?
      object.create_etymology_type_association(association_params)
    end
    if originally_valid && !object.valid?
      object.destroy!
      @object = Etymology.new(etymology_params)
      object.build_etymology_type_association(etymology_type_association_params[:etymology_type_association_attributes])
    end
  end
  
  create do
    wants.html do
      if object.valid? #failure.wants.html does not seem to work
        redirect_to(polymorphic_url([:admin, object.context, object]))
      else
        flash[:notice] = 'Etymology type associations failed to save.'
        render :new
      end
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
