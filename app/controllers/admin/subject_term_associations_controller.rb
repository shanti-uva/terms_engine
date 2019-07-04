class Admin::SubjectTermAssociationsController < AclController
  include KmapsEngine::ResourceObjectAuthentication
  resource_controller

  belongs_to :feature

  new_action.wants.html do
    if params[:branch_id]
      object.branch_id = params[:branch_id]
    end
  end

  protected

  # Only allow a trusted parameter "white list" through.
  def subject_term_association_params
    params.require(:subject_term_association).permit(:feature_id, :subject_id, :branch_id)
  end
end
