require 'nokogiri'
require 'kmaps_engine/progress_bar'

module TermsEngine
  class XmlImportation
    include KmapsEngine::ProgressBar

    attr_accessor :spreadsheet, :xml_word, :definition, :author, :info_source, :shanti_source, :collection
    
    def do_feature_import(filename:, task_code:, source:, source_id:, author_name:, collection:)
      puts "#{Time.now}: Starting importation."
      doc = Nokogiri::XML(open(filename))
      task = ImportationTask.find_by(task_code: task_code)
      task = ImportationTask.create(:task_code => task_code) if task.nil?
      self.log.debug { "#{Time.now}: Starting importation." }
      self.spreadsheet = task.spreadsheets.find_by(filename: filename)
      self.spreadsheet = task.spreadsheets.create(:filename => filename, :imported_at => Time.now) if self.spreadsheet.nil?
      self.get_source(source, source_id, task_code)
      self.get_author(author_name)
      self.get_collection(collection, task_code, source)
      current = 0
      xml_words = doc.xpath('//body/div/div') #/'div[n=1]'
      total = xml_words.count
      puts "#{Time.now}: Processing features..."
      fids_to_reindex = Array.new
      xml_words.each do |current_word|
        begin
          self.xml_word = current_word
          self.get_main_feature
          self.add_affiliation
          self.process_word_metadata
          self.reset_definition
          self.progress_bar(num: current, total: total, current: self.feature.pid)
          self.log.debug { "#{Time.now}: #{self.feature.pid} processed." }
          current+=1
        rescue Exception => e
          STDOUT.flush
          word_str = self.xml_word.at('head').text.strip
          say "Uncaught error while processing #{word_str}."
          self.log.fatal { "#{Time.now}: An error occured when processing #{Process.pid}:" }
          self.log.fatal { e.message }
          self.log.fatal { e.backtrace.join("\n") }
        end
      end
    end
    
    def get_main_feature
      self.feature = XmlImportation.get_feature(self.xml_word.at('head').text.strip)
    end
    
    def self.get_feature(word_str)
      feature = Feature.search_bod_expression(word_str)
      if feature.nil?
        last_char = word_str[word_str.size-1]
        if last_char!='/'
          if word_str[word_str.size-2..word_str.size-1]=='ng'
            word_str1 = word_str + ' /'
            feature = Feature.search_bod_expression(word_str1)
            word_str << ' /' if feature.nil?
          elsif last_char != 'g'
            word_str << '/'
          end
        end
        feature = Feature.search_bod_expression(word_str) if feature.nil?
      end
      return feature
    end
    
    def definition
      @definition ||= self.get_definition(self.feature)
    end
    
    def reset_definition
      @definition = nil
    end
    
    def get_definition(term)
      definition = term.definitions.joins(:citations).where('citations.info_source' => self.info_source).first
      if definition.nil?
        @english_language ||= Language.get_by_code('eng')
        begin
          definition = term.definitions.create!(content: '', is_public: true, author: self.author, language: @english_language)
          citation = definition.citations.create!(info_source: self.info_source)
        rescue ActiveRecord::RecordInvalid => invalid
          say "Definition could not be created for #{term.pid}: #{invalid.to_s}"
          byebug
          definition = nil
        end
      end
      return definition
    end
    
    def get_collection(name, code, description)
      options = {name: name, code: code, description: description}
      collection = Collection.where(options).first
      if collection.nil?
        begin
          collection = Collection.create!(options)
          self.spreadsheet.imports.create(item: collection)
        rescue ActiveRecord::RecordInvalid => invalid
          say "Collection could not be created for #{name}: #{invalid.to_s}"
          byebug
          collection = nil
        end
      end
      self.collection = collection
    end
        
    def get_author(author_name)
      options = {fullname: author_name}
      author = AuthenticatedSystem::Person.find_by(options)
      if author.nil?
        begin
          author = AuthenticatedSystem::Person.create!(options)
          self.spreadsheet.imports.create(item: author)
        rescue ActiveRecord::RecordInvalid => invalid
          say "Author could not be created for #{author_name}: #{invalid.to_s}"
          byebug
          author = nil
        end
      end
      self.author = author
    end
    
    def get_source(title, source_id, code)
      options = { title: title, code: code, processed: true }
      info_source = InfoSource.where(options).first
      if info_source.nil?
        begin
          info_source = InfoSource.create!(options) 
          self.spreadsheet.imports.create(item: info_source)
        rescue ActiveRecord::RecordInvalid => invalid
          say "Info source could not be created for #{title}: #{invalid.to_s}"
          byebug
        end
      end
      self.shanti_source = ShantiIntegration::Source.find(source_id)
      self.info_source = info_source #ShantiIntegration::Source.find(source_id)
    end
            
    def process_word_metadata
      sections = self.xml_word.xpath('div') #/'div[n=3]'
      sections.each do |section|
        section_head_str = section.at('head').text.strip
        case
        when section_head_str == 'Cross Reference'
          self.process_cross_reference(section.at('p').text.strip)
        when section_head_str == 'Note'
          self.process_note(self.definition, section.xpath('p').to_s.strip)
        when section_head_str.start_with?('Translation')
          self.process_translation_equivalent(section_head_str)
        else
          #Citations
          citation_source = section_head_str
          citation_metadata = section.xpath('p').collect(&:text)
          sources_to_add = XmlImportation.extract_sources(citation_metadata)
          note_for_passage = []
          note_for_translation = []
          translation_for_passage = []
          last_passage = nil
          last_translation = nil
          subsections = section.xpath('div')
          heads_array = subsections.xpath('head').collect{ |x| x.text.strip }
          heads_hash = { 'Passage' => 0, 'Translation' => 0, 'Note' => 0, 'Cross Reference' => 0 }
          heads_array.each do |e|
            byebug if heads_hash[e].nil?
            heads_hash[e] += 1
          end
          subsections.each do |subsection|
            subsection_head_str = subsection.at('head').text.strip
            case subsection_head_str
            when 'Cross Reference'
              relation = self.process_cross_reference(subsection.at('p').text.strip)
              self.process_citations(relation, sources_to_add)
              subnote = subsection.at('div')
              if !subnote.nil? && subnote.at('head').text.strip=='Note'
                subnote_str = subnote.xpath('p').to_s.strip
                self.process_note(relation, subnote_str)
              end
            when 'Note'
              note_str = subsection.xpath('p').to_s.strip
              next_elem = subsection.next
              if heads_hash['Passage']==1
                if !last_passage.nil?
                  self.process_note(last_passage, note_str)
                else
                  note_for_passage << note_str
                end
              else
                if heads_hash['Passage']>1
                  if !next_elem.nil? && next_elem.at('head').text=='Passage'
                    note_for_passage << note_str
                  else
                    if !last_passage.nil?
                      self.process_note(last_passage, note_str)
                    else
                      note_for_passage << note_str
                    end
                  end
                else
                  # No passages. Try translations
                  if heads_hash['Translation']==1
                    if !last_translation.nil?
                      self.process_note(last_translation, note_str)
                    else
                      note_for_translation << note_str
                    end
                  else
                    if heads_hash['Translation']>1
                      if !next_elem.nil? && next_elem.at('head').text=='Translation'
                        note_for_translation << note_str
                      else
                        if !last_translation.nil?
                          self.process_note(last_translation, note_str)
                        else
                          note_for_translation << note_str
                        end
                      end
                    else
                      # No translation either.
                      self.process_citations(self.definition, sources_to_add, note_str)
                    end
                  end
                end
              end
            when 'Translation'
              #TODO handle translation note for citation
              #XmlImportation.process_translation(section_head_str)
              translation_str = subsection.xpath('p').to_s.strip
              next_elem = subsection.next
              translation = nil
              if heads_hash['Passage']==1
                if !last_passage.nil?
                  translation = self.process_passage_translation(last_passage, translation_str)
                else
                  translation_for_passage << translation_str
                end
              else
                if heads_hash['Passage']>1
                  if !next_elem.nil? && next_elem.at('head').text=='Passage'
                    translation_for_passage << translation_str
                  else
                    if !last_passage.nil?
                      translation = self.process_passage_translation(last_passage, translation_str)
                    else
                      translation_for_passage << translation_str
                    end
                  end
                else
                  # No passages.
                  translation = self.process_passage_translation(self.definition, translation_str)
                end
              end
              if !translation.nil?
                note_for_translation.each{ |n| self.process_note(translation, n) }
                note_for_translation = []
                self.process_citations(translation, sources_to_add)
                last_translation = translation
              end
            when 'Passage'
              passage_str = subsection.xpath('p').to_s.strip
              passage_str = subsection.xpath('list').to_s.strip if passage_str.empty?
              passage = self.process_passage(passage_str)
              self.process_citations(passage, sources_to_add)
              note_for_passage.each{ |n| self.process_note(passage, n) }
              note_for_passage = []
              translation_for_passage.each{ |t| self.process_passage_translation(passage, t) }
              translation_for_passage = []
              last_passage = passage
            end
          end
          if !(note_for_passage.blank? && note_for_translation.blank? && translation_for_passage.blank?)
            byebug
          end
        end
      end
    end
    
    def self.extract_sources(metadata)
      sources = []
      source = {}
      metadata.each do |line|
        fields = line.split(':')
        key = fields[0].strip
        value = fields[1].blank? ? nil : fields[1].strip
        if key == 'Source'
          if source['id'].nil?
            source['id'] = value.to_i
          else
            sources << source
            source = {'id' => value}
          end
        else
          source[key] = value
        end
      end
      sources << source
      return sources
    end
    
    def process_citations(citable, sources, note = nil)
      sources.each{ |source| self.process_citation(citable, source, note) }
    end
    
    def add_affiliation
      @perspective ||= Perspective.get_by_code('tib.alpha')
      options = {descendants: false, perspective: @perspective, collection: self.collection}
      affiliations = self.feature.affiliations
      affiliation = affiliations.where(options).first
      if affiliation.nil?
        begin
          affiliation = affiliations.create!(options)
          self.spreadsheet.imports.create(item: affiliation)
        rescue ActiveRecord::RecordInvalid => invalid
          say "Affiliation could not be added for feature #{self.feature.pid}: #{invalid.to_s}"
          byebug
          return nil
        end
      end
      return affiliation
    end
    
    def add_citation(citable, source_id, note = nil)
      options = { info_source_type: ShantiIntegration::Source.model_name.name, info_source_id: source_id, notes: note }
      citations = citable.citations
      citation = citations.where(options).first
      if citation.nil?
        begin
          citation = citations.create!(options)
          self.spreadsheet.imports.create(item: citation)
        rescue ActiveRecord::RecordInvalid => invalid
          say "Citation could not be created under #{citable.model_name.human} #{citable.id}: #{invalid.to_s}"
          byebug
          return nil
        end
      end
      return citation
    end
    
    def process_citation(citable, metadata, note = nil)
      citation = self.add_citation(citable, metadata['id'], note)
      # Handle the following citation fields for word_str: Chapter, International Page Start, Start Line
      # Tibetan Page Start, Verse End, Verse Start, Volume #
      #puts citation_source
      
      pages = citation.pages
      options = { chapter: metadata['Chapter'], start_line: metadata['Start Line'], end_verse: metadata['Verse End'], start_verse: metadata['Verse Start'],
        volume: metadata['Volume #'], start_page: metadata['International Page Start'], tibetan_start_page: metadata['Tibetan Page Start'] }
      page = pages.where(options).first
      if page.nil?
        begin
          page = pages.create!(options)
          self.spreadsheet.imports.create(item: page)
        rescue ActiveRecord::RecordInvalid => invalid
          say "Page could not be created under citation #{citation.id}: #{invalid.to_s}"
          byebug
        end
      end
      return citation
    end
    
    def process_cross_reference(reference)
      relation_array = reference.split(':')
      related_str = relation_array[0].strip
      relation_str = relation_array[1].blank? ? nil : relation_array[1].strip
      relation_code = relation_str.gsub(/ /, '.')
      #TODO establish relationship 'code' between 'related' and 'word_str'
      related_feature = XmlImportation.get_feature(related_str)
      @perspective ||= Perspective.get_by_code('tib.alpha')
      relation_type = FeatureRelationType.get_by_code(relation_code)
      if !relation_type.nil?
        options = { child_node: self.feature, perspective: @perspective, feature_relation_type: relation_type }
        feature_relations = related_feature.all_child_relations
      else
        relation_type = FeatureRelationType.get_by_asymmetric_code(relation_code)
        options = { child_node: related_feature, perspective: @perspective, feature_relation_type: relation_type }
        feature_relations = self.feature.all_child_relations
      end
      relation = feature_relations.where(options).first
      if relation.nil?
        begin
          relation = feature_relations.create!(options)
          self.add_citation(relation, self.shanti_source.id)
          self.spreadsheet.imports.create(item: relation)
        rescue ActiveRecord::RecordInvalid => invalid
          say "Relation between #{self.feature.pid} and #{related_feature.pid} could not be created: #{invalid.to_s}"
          byebug
          relation = nil
        end
      end
      return relation
    end
    
    def process_note(notable, note_str)
      notes = notable.notes
      options = { content: note_str }
      byebug if notes.nil?
      note = notes.where(options).first
      if note.nil?
        begin
          note = notes.create!(options)
          self.spreadsheet.imports.create(item: note)
          note.authors << self.author
        rescue ActiveRecord::RecordInvalid => invalid
          say "Note #{note_str} could not be created: #{invalid.to_s}"
          byebug
          note = nil
        end
      end
      return note
    end
    
    def process_translation_equivalent(translation_str)
      language_str = translation_str.gsub(/.+\((.+)\).+/,'\1')
      translation_str = translation_str.split(':')[1]
      translation_str.strip! if !translation_str.blank?
      language = Language.get_by_name(language_str)
      translations = self.feature.translation_equivalents
      options = { content: translation_str, language: language }
      translation = translations.where(options).first
      if translation.nil?
        begin
          translation = translations.create!(options)
          self.add_citation(translation, self.shanti_source.id)
          self.spreadsheet.imports.create(item: translation)
        rescue ActiveRecord::RecordInvalid => invalid
          say "Translation equivalent #{translation_str} could not be created: #{invalid.to_s}"
          byebug
          translation = nil
        end
      end
      return translation
    end
    
    def process_passage(passage_str)
      passages = self.definition.passages
      options = { content: passage_str }
      passage = passages.where(options).first
      if passage.nil?
        begin
          passage = passages.create!(options)
          self.spreadsheet.imports.create(item: passage)
        rescue ActiveRecord::RecordInvalid => invalid
          say "Passage #{passage_str} could not be created: #{invalid.to_s}"
          byebug
          passage = nil
        end
      end
      
      return passage
    end
    
    def process_passage_translation(translatable, translation_str)
      translations = translatable.passage_translations
      language = Language.get_by_code('eng')
      options = { content: translation_str, language: language }
      translation = translations.where(options).first
      if translation.nil?
        begin
          translation = translations.create!(options)
          self.spreadsheet.imports.create(item: translation)
        rescue ActiveRecord::RecordInvalid => invalid
          say "Passage translation #{translation_str} could not be created: #{invalid.to_s}"
          byebug
          translation = nil
        end
      end
      return translation
    end
  end
end