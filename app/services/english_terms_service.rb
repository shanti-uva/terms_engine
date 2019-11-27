class EnglishTermsService

  def initialize(arg = nil)
    if arg.nil?
      @terms = Feature.current_roots_by_perspective(Perspective.get_by_code('eng.alpha'))
    elsif arg.instance_of? Array
      @terms = arg
    elsif arg.instance_of? Feature
      @terms = arg.children.order(:position)
    end
  end
  
  def terms
    @terms
  end
  
  def sorted_terms
    if @sorted_terms.nil?
      @view ||= View.get_by_code('roman.scholar')
      terms_with_name = terms.collect{|t| [t, t.prioritized_name(@view).name] }
      sorted_terms_with_name = terms_with_name.sort{ |a,b| a[1].downcase <=> b[1].downcase }
      @sorted_terms = sorted_terms_with_name.collect(&:first)
    end
    @sorted_terms
  end
  
  def names
    if @names.nil?
      @view ||= View.get_by_code('roman.scholar')
      @names = terms.collect{|t| t.prioritized_name(@view).name}
    end
    @names
  end
  
  def trunk_for(name)
    pos = position_for(name)
    pos.nil? ? terms[terms.size-1] : terms[pos]
  end
    
  def position_for(name)
    pos = names.find_index{|n| (n.downcase <=> name.downcase) >= 0}
    pos.nil? || pos==0 ? nil : pos - 1
  end
  
  def self.recursive_trunk_for(name)
    letters = EnglishTermsService.new
    letter = letters.trunk_for(name)
    return nil if letter.nil?
    #TODO: We need to handle the case when there are no items in the letter
    EnglishTermsService.new(letter).trunk_for(name)
  end
  
  def reposition
    sorted = self.sorted_terms
    sorted.each_index { |i| sorted[i].update_attribute(:position, i+1) }
  end

  def self.add_term(subject_id, term_name)
    if subject_id == Feature::ENG_LETTER_SUBJECT_ID
      f = Feature.search_by_phoneme(term_name, Feature::ENG_LETTER_SUBJECT_ID)
    else
      f = Feature.search_by_excluding_phoneme(term_name, Feature::ENG_PHONEME_SUBJECT_ID, Feature::ENG_LETTER_SUBJECT_ID)
    end
    return f if !f.nil?
    f = Feature.create!(fid: Feature.generate_pid, is_public: 1)
    @@english_language ||= Language.get_by_code('eng')
    @@latin_script ||= WritingSystem.get_by_code('latin')
    
    names = f.names
    # TODO: Validate that the name was created succesfully or notify the user
    english_name = names.create!(skip_update: true, name: term_name, position: 0, writing_system: @@latin_script, language: @@english_language, is_primary_for_romanization: true)
    # TODO: Validate that the subject_term_association was created succesfully or notify the user
    a = f.subject_term_associations.create(subject_id: subject_id, branch_id: Feature::ENG_PHONEME_SUBJECT_ID)
    return f
  end
end
