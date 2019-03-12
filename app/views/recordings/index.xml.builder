xml.instruct!
xml.recordings do
  @recordings.each do |recording|
    xml << render(partial: 'show', locals: { recording: recording })
  end
end
