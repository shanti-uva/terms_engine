class Assistant
  include ActiveModel::Model
  @@keys = [:passage, :translated_passage, :base_dictionary_id, :destination_dictionary_id, :language_id]
  @@keys.each{|k| attr_accessor k }
  
  def base_dictionary
    base_dictionary_id.blank? ? nil : InfoSource.find(base_dictionary_id)
  end
  
  def destination_dictionary
    destination_dictionary_id.blank? ? nil : InfoSource.find(destination_dictionary_id)
  end
  
  def language
    language_id.blank? ? nil : Language.find(language_id)
  end
  
  def to_h
    h = {}
    @@keys.each do |k| 
      val = self.send(k)
      h[k] = val if !val.blank?
    end
    h
  end
end
