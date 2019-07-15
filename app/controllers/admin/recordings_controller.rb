class Admin::RecordingsController < AclController
  include KmapsEngine::ResourceObjectAuthentication
  resource_controller

  belongs_to :feature

  protected

  # Only allow a trusted parameter "white list" through.
  def recording_params
    params.require(:recording).permit(:feature_id, :dialect_id, :audio_file)
  end
end
