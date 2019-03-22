json.recordings do
  json.array! @recordings, partial: 'show', as: :recording
end
