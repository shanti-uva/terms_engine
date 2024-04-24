class Admin::EtymologySubjectAssociationsController < AclController
  include KmapsEngine::ResourceObjectAuthentication
  resource_controller

  belongs_to :etymology

  new_action.before { object.branch_id = params[:branch_id] if params[:branch_id] }

  create.wants.html  { redirect_to polymorphic_url(helpers.stacked_parents) }
  update.wants.html  { redirect_to polymorphic_url(helpers.stacked_parents) }
  destroy.wants.html { redirect_to polymorphic_url(helpers.stacked_parents) }

  protected

  # Only allow a trusted parameter "white list" through.
  def etymology_subject_association_params
    params.require(:etymology_subject_association).permit(:etymology_id, :subject_id, :branch_id)
  end
end
