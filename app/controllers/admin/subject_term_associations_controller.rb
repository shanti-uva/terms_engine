class Admin::SubjectTermAssociationsController < AclController
  include KmapsEngine::ResourceObjectAuthentication
  resource_controller

  belongs_to :feature

  new_action.before { object.branch_id = params[:branch_id] if params[:branch_id] }
  create.wants.html { redirect_to admin_feature_path(object.feature.fid, section: 'subjectAssociations') }
  update.wants.html { redirect_to admin_feature_path(object.feature.fid, section: 'subjectAssociations') }
  protected

  # Only allow a trusted parameter "white list" through.
  def subject_term_association_params
    params.require(:subject_term_association).permit(:feature_id, :subject_id, :branch_id)
  end
end
