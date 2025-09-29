class Admin::RecordingsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  include KmapsEngine::ResourceObjectAuthentication
  resource_controller
  belongs_to :feature
  
  create.wants.html { redirect_to admin_feature_path(object.feature.fid, section: 'recordings') }
  update.wants.html { redirect_to admin_feature_path(object.feature.fid, section: 'recordings') }

  protected

  # Only allow a trusted parameter "white list" through.
  def recording_params
    params.require(:recording).permit(:feature_id, :dialect_id, :audio_file)
  end
end
