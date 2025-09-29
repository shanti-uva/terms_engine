class RecordingsController < ApplicationController
  allow_unauthenticated_access

  # GET /recordings
  def index
    feature = Feature.get_by_fid(params[:feature_id])
    @recordings = []
    if !feature.nil?
      @recordings = Recording.where(feature_id: feature.id)
    end
    respond_to do |format|
      format.xml
      format.json
    end
  end

  # GET /recordings/1
  def show
    feature = params[:feature_id].blank? ? nil : Feature.get_by_fid(params[:feature_id])
    @recording = feature.nil? ? Recording.find(params[:id]) : feature.recordings.find(params[:id])
    respond_to do |format|
      format.xml
      format.json
    end
  end
end
