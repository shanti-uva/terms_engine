class TibetanTermsService
  def initialize(arg = nil)
    if arg.nil?
      @terms = Feature.current_roots_by_perspective(Perspective.get_by_code('tib.alpha'))
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
      @view ||= View.get_by_code('pri.orig.sec.roman')
      terms_with_name = terms.collect{|t| [t, t.prioritized_name(@view).name] }
      sorted_terms_with_name = terms_with_name.sort{ |a,b| a[1].bo_compare(b[1]) }
      @sorted_terms = sorted_terms_with_name.collect(&:first)
    end
    @sorted_terms
  end
  
  def names
    if @names.nil?
      @view ||= View.get_by_code('pri.orig.sec.roman')
      @names = terms.collect{|t| t.prioritized_name(@view).name}
    end
    @names
  end
  
  def trunk_for(name)
    pos = position_for(name)
    pos.nil? ? terms[terms.size-1] : terms[pos]
  end
    
  def position_for(name)
    pos = names.find_index { |n| n.bo_compare(name)>0 }
    pos.nil? || pos==0 ? nil : pos - 1
  end
  
  def self.recursive_trunk_for(name)
    if name.instance_of? String
      letters = TibetanTermsService.new
      letter = letters.trunk_for(name)
      return letter.nil? ? nil : TibetanTermsService.new(letter).trunk_for(name)
    elsif name.instance_of? Feature
      @view ||= View.get_by_code('pri.orig.sec.roman')
      name_str = name.prioritized_name(@view).name
      letters_a = Feature.current_roots_by_perspective(Perspective.get_by_code('tib.alpha'))
      letters_a.reject! do |l|
        a = l.phoneme_term_associations.first
        a.nil? || a.subject_id != Feature::BOD_LETTER_SUBJECT_ID
      end
      letters = TibetanTermsService.new(letters_a)
      letter = letters.trunk_for(name_str)
      return letter.nil? ? nil : TibetanTermsService.new(letter).trunk_for(name_str)
    else
      return nil
    end
  end
  
  def reposition
    sorted = sorted_terms
    sorted.each_index do |i|
      new_position = i+1
      term = sorted[i]
      if term.position != new_position
        term.update(position: i+1, skip_update: true)
        term.queued_index
      end
    end
  end

  def self.get_wylie(name)
    response = Faraday.get "http://www.thlib.org/cgi-bin/thl/lbow/wylie.pl", { plain: :true, conversion: :uni2wy, input: name.tibetan_cleanup }
    if response.body == "[#{name}]"
      return nil
    else
      return response.body
    end
  end
  def self.get_phonetic(name)
    response = Faraday.get "http://www.thlib.org/cgi-bin/thl/lbow/phonetics.pl", { plain: :true, input: name.tibetan_cleanup }
    if response.body.include? "\n---\n"
      return nil
    else
      return response.body
    end
  end
  
  def self.add_term(level_subject_id, tibetan = nil, wylie = nil, phonetic = nil)
    f = Feature.search_by_phoneme(tibetan || wylie, level_subject_id)
    return f if !f.nil?
    f = Feature.create!(fid: Feature.generate_pid, is_public: 1, skip_update: true)
    @@tibetan_script ||= WritingSystem.get_by_code('tibt')
    @@tibetan_language ||= Language.get_by_code('bod')
    @@latin_script ||= WritingSystem.get_by_code('latin')
    @@wylie_system ||= OrthographicSystem.get_by_code('thl.ext.wyl.translit')
    @@thl_phonetic ||= PhoneticSystem.get_by_code('thl.simple.transcrip')
    
    names = f.names
    if !tibetan.blank?
      tibetan_name = names.create!(skip_update: true, name: tibetan, position: 0, writing_system: @@tibetan_script, language: @@tibetan_language, is_primary_for_romanization: false)
    end
    if !wylie.blank?
      wylie_name = names.create!(skip_update: true, name: wylie, position: 1, writing_system: @@latin_script, language: @@tibetan_language, is_primary_for_romanization: true)
      if !tibetan_name.nil?
        relation = FeatureNameRelation.create!(skip_update: true, parent_node: tibetan_name, child_node: wylie_name, is_phonetic: 0, is_orthographic: 1, is_translation: 0, is_alt_spelling: 0, orthographic_system: @@wylie_system)
      end
    end
    if !phonetic.blank?
      phonetic_name = names.create!(skip_update: true, name: phonetic, position: 2, writing_system: @@latin_script, language: @@tibetan_language, is_primary_for_romanization: false)
      if !tibetan_name.blank? || !wylie_name.blank?
        relation = FeatureNameRelation.create!(skip_update: true, parent_node: tibetan_name || wylie_name, child_node: phonetic_name, is_phonetic: 1, is_orthographic: 0, is_translation: 0, is_alt_spelling: 0, phonetic_system: @@thl_phonetic)
      end
    end
    a = f.subject_term_associations.create(subject_id: level_subject_id, branch_id: Feature::BOD_PHONEME_SUBJECT_ID)
    return f
  end
end
