class NewariTermsService
  def initialize(arg = nil)
    if arg.nil?
      @terms = Feature.current_roots_by_perspective(Perspective.get_by_code('new.alpha'))
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
      sorted_terms_with_name = terms_with_name.sort{ |a,b| a[1].new_compare(b[1]) }
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
    pos = names.find_index { |n| n.new_compare(name)>0 }
    pos.nil? || pos==0 ? nil : pos - 1
  end
  
  def self.recursive_trunk_for(name)
    if name.instance_of? String
      letters = NewariTermsService.new
      letter = letters.trunk_for(name)
      return letter.nil? ? nil : NewariTermsService.new(letter).trunk_for(name)
    elsif name.instance_of? Feature
      @view ||= View.get_by_code('pri.orig.sec.roman')
      name_str = name.prioritized_name(@view).name
      letters_a = Feature.current_roots_by_perspective(Perspective.get_by_code('tib.alpha'))
      letters_a.reject! do |l|
        a = l.phoneme_term_associations.first
        a.nil? || a.subject_id != Feature::NEW_LETTER_SUBJECT_ID
      end
      letters = NewariTermsService.new(letters_a)
      letter = letters.trunk_for(name_str)
      return letter.nil? ? nil : NewariTermsService.new(letter).trunk_for(name_str)
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
  
  def self.add_term(level_subject_id:, deva: nil, latin: nil, fid: nil)
    f = Feature.search_by_phoneme(deva || latin, level_subject_id)
    return f if !f.nil?
    attrs = { is_public: 1, skip_update: true }
    if fid.nil?
      f = Feature.create!(attrs.merge({ fid: Feature.generate_pid }))
    else
      f = Feature.get_by_fid(fid)
      return f if f.nil? || !f.is_blank?
      f.update(attrs)
    end
    @@deva_script ||= WritingSystem.get_by_code('deva')
    @@newari_language ||= Language.get_by_code('new')
    @@latin_script ||= WritingSystem.get_by_code('latin')
    @@indo_system ||= OrthographicSystem.get_by_code('indo.standard.translit')
    
    names = f.names
    if !deva.blank?
      deva_name = names.create!(skip_update: true, name: deva, position: 0, writing_system: @@deva_script, language: @@newari_language, is_primary_for_romanization: false)
    end
    if !latin.blank?
      latin_name = names.create!(skip_update: true, name: latin, position: 1, writing_system: @@latin_script, language: @@newari_language, is_primary_for_romanization: true)
      if !deva_name.nil?
        relation = FeatureNameRelation.create!(skip_update: true, parent_node: deva_name, child_node: latin_name, is_phonetic: 0, is_orthographic: 1, is_translation: 0, is_alt_spelling: 0, orthographic_system: @@indo_system)
      end
    end
    a = f.subject_term_associations.create(subject_id: level_subject_id, branch_id: Feature::NEW_PHONEME_SUBJECT_ID)
    return f
  end
end
