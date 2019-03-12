xml.recording do
  xml.id recording.id, type: 'integer'
  xml.feature_id recording.feature_id, type: 'integer'
  xml.audio_file polymorphic_url(recording.audio_file)
end
