xml.instruct!
xml.info_sources(type: 'array') do
  collection.each do |info_source|
    xml.info_source do
      xml.id(info_source.id, type: 'integer')
      xml.agent(info_source.agent)
      xml.code(info_source.code)
      xml.date_published(info_source.date_published, type: 'date')
      xml.position(info_source.position, type: 'integer')
      xml.processed(info_source.processed, type: 'boolean')
      xml.title(info_source.title)
      xml.created_at(info_source.created_at, type: 'datetime')
      xml.updated_at(info_source.updated_at, type: 'datetime')
      xml.language(info_source.language.code) 
    end
  end
end
