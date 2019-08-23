class Admin::EtymologySubjectAssociationsController < AclController
  include KmapsEngine::ResourceObjectAuthentication
  resource_controller

  belongs_to :etymology

  new_action.before { object.branch_id = params[:branch_id] if params[:branch_id] }

  destroy.wants.html { redirect_to polymorphic_url([:admin,object.etymology]) }

  protected

  # Only allow a trusted parameter "white list" through.
  def etymology_subject_association_params
    params.require(:etymology_subject_association).permit(:etymology_id, :subject_id, :branch_id)
  end
end
