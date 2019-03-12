json.recording do
  json.partial! 'show', locals: { recording: @recording }
end
