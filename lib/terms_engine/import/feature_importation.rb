require 'kmaps_engine/import/feature_importation'

module TermsEngine
  class FeatureImportation < KmapsEngine::FeatureImportation
    attr_accessor :last_parent
    attr_accessor :perspective
    attr_accessor :main_names
    
    # Currently supported fields:
    # features.fid, features.old_pid, features.position, feature_names.delete, feature_names.is_primary.delete
    # i.feature_names.existing_name
    # i.feature_names.name, i.feature_names.position, i.feature_names.is_primary,
    # i.languages.code/name, i.writing_systems.code/name, i.alt_spelling_systems.code/name
    # i.phonetic_systems.code/name, i.orthographic_systems.code/name, BOTH DEPRECATED, INSTEAD USE: i.feature_name_relations.relationship.code
    # i.feature_name_relations.parent_node, i.feature_name_relations.is_translation, 
    # i.feature_name_relations.is_phonetic, i.feature_name_relations.is_orthographic, BOTH DEPRECATED AND USELESS
    # feature_relations.delete, [i.]feature_relations.related_feature.fid or [i.]feature_relations.related_feature.name,
    # [i.]feature_relations.type.code, [i.]perspectives.code/name, feature_relations.replace
    # [i.]definitions.content, [i.]definitions.languages.code/name
    # [i].definitions.[j].model_sentence
    
    # Fields that accept time_units:
    # features, i.feature_names[.j]

    # time_units fields supported:
    # .time_units.[start.|end.]date, .time_units.[start.|end.]certainty_id, .time_units.season_id,
    # .time_units.calendar_id, .time_units.frequency_id

    # Fields that accept info_source:
    # [i.]feature_names[.j], [i.]definitions[.j], [i.]translations[.j]

    # info_source fields:
    # .info_source.id/code, info_source.note, info_source.title
    # When info source is a document: .info_source[.i].volume, info_source[.i].pages
    # When info source is an online resource: .info_source[.i].path, .info_source[.i].name

    # Fields that accept note:
    # [i.]feature_names[.j]

    # Note fields:
    # .note

    def do_feature_import(filename:, task_code:, perspective_code:)
      puts "#{Time.now}: Starting importation."
      task = ImportationTask.find_by(task_code: task_code)
      task = ImportationTask.create(:task_code => task_code) if task.nil?
      self.last_parent = nil
      self.perspective = Perspective.get_by_code(perspective_code)
      self.log.debug { "#{Time.now}: Starting importation." }
      self.spreadsheet = task.spreadsheets.find_by(filename: filename)
      self.spreadsheet = task.spreadsheets.create(:filename => filename, :imported_at => Time.now) if self.spreadsheet.nil?
      interval = TermsEngine::ApplicationSettings.import_interval || 100
      rows = CSV.read(filename, headers: true, col_sep: "\t")
      current = 0
      total = rows.size
      ipc_reader, ipc_writer = IO.pipe('ASCII-8BIT')
      ipc_writer.set_encoding('ASCII-8BIT')
      puts "#{Time.now}: Processing features..."
      STDOUT.flush
      feature_ids_with_changes_accumulated = Array.new
      while current<total
        limit = current + interval
        limit = total if limit > total
        sid = Spawnling.new(kill: true) do
          begin
            self.log.debug { "#{Time.now}: Spawning sub-process #{Process.pid}." }
            ipc_reader.close
            feature_ids_with_changes = Array.new
            for i in current...limit
              row = rows[i]
              self.fields = row.to_hash.delete_if{ |key, value| value.blank? }
              self.get_main_names
              if self.fields['features.fid'].blank?
                self.infer_feature
                self.set_up_main_names_for_new_or_blank_feature if self.feature.nil?
                self.process_feature
              else
                next unless self.get_feature(current)
                is_blank = self.feature.is_blank?
                self.set_up_main_names_for_new_or_blank_feature if is_blank
                self.process_feature
                self.process_names(44) if !is_blank
              end
              feature_ids_with_changes << self.feature.id
              self.process_kmaps(5)
              process_definitions(87)
              process_translations(64)
              feature_ids_with_changes.concat(process_feature_relations(10))
              self.progress_bar(num: i, total: total, current: self.feature.pid)
              if self.fields.empty?
                self.log.debug { "#{Time.now}: #{self.feature.pid} processed." }
              else
                self.log.warn { "#{Time.now}: #{self.feature.pid}: the following fields have been ignored: #{self.fields.keys.join(', ')}" }
              end
            end
            ipc_hash = { bar: self.bar, num_errors: self.num_errors, valid_point: self.valid_point, changes: feature_ids_with_changes, last_parent_fid: self.last_parent.nil? ? nil : self.last_parent.fid }
            data = Marshal.dump(ipc_hash)
            ipc_writer.puts(data.length)
            ipc_writer.write(data)
            ipc_writer.flush
            ipc_writer.close
          rescue Exception => e
            STDOUT.flush
            self.log.fatal { "#{Time.now}: An error occured:" }
            self.log.fatal { e.message }
            self.log.fatal { e.backtrace.join("\n") }
          end
        end
        Spawnling.wait([sid])
        size = ipc_reader.gets
        data = ipc_reader.read(size.to_i)
        ipc_hash = Marshal.load(data)
        feature_ids_with_changes = ipc_hash[:changes]
        feature_ids_with_changes_accumulated.concat(feature_ids_with_changes)
        feature_ids_with_changes_accumulated.uniq!
        self.update_progress_bar(bar: ipc_hash[:bar], num_errors: ipc_hash[:num_errors], valid_point: ipc_hash[:valid_point])
        self.last_parent = Feature.get_by_fid(ipc_hash[:last_parent_fid]) if !ipc_hash[:last_parent_fid].nil?
        current = limit
      end
      ipc_writer.close
      puts "#{Time.now}: Reindexing changed features..."
      STDOUT.flush
      feature_ids_with_changes_accumulated.sort!
      feature_ids_with_changes_accumulated.each_index do |i|
        id = feature_ids_with_changes_accumulated[i]
        feature = Feature.find(id)
        feature.skip_update = false
        feature.queued_index
        self.progress_bar(num: i, total: feature_ids_with_changes_accumulated.size, current: feature.pid)
        self.log.debug "#{Time.now}: Reindexed feature #{feature.fid}."
      end
      reposition_parent if !self.last_parent.nil?
      puts "#{Time.now}: Importation done."
    end
    
    def get_info_source(field_prefix)
      info_source = nil
      return nil if self.fields.keys.find{|k| !k.nil? && k.starts_with?("#{field_prefix}.info_source")}.nil?
      begin
        info_source_id = self.fields.delete("#{field_prefix}.info_source.id")
        if info_source_id.blank?
          info_source_code = self.fields.delete("#{field_prefix}.info_source.code")
          if info_source_code.blank?
            source_name = self.fields.delete("#{field_prefix}.info_source.oral.fullname")
            if source_name.blank?
              source_title = self.fields.delete("#{field_prefix}.info_source.title")
              if !source_title.blank?
                info_source = InfoSource.where(title: source_title).first
              end
            else
              info_source = OralSource.find_by_name(source_name)
              self.say "Oral source with name #{source_name} was not found." if info_source.nil?
            end
          else
            info_source = InfoSource.get_by_code(info_source_code)
            self.say "Info source with code #{info_source_code} was not found." if info_source.nil?
          end
        else
          info_source = ShantiIntegration::Source.find(info_source_id)
          self.say "Info source with Shanti Source ID #{info_source_id} was not found." if info_source.nil?
        end
      rescue Exception => e
        self.say e.to_s
      end
      return info_source
    end
    
    def get_main_names
      case self.perspective.code
      when 'tib.alpha'
        tibetan_str = nil
        wylie_str = nil
        phonetic_str = nil
        1.upto(3) do |i|
          name_tag = "#{i}.feature_names"
          name_str = self.fields.delete("#{name_tag}.name")
          writing_system_str = self.fields.delete("#{i}.writing_systems.code")
          relationship_system_str = self.fields.delete("#{i}.feature_name_relations.relationship.code")
          if writing_system_str=='tibt'
            tibetan_str = name_str.tibetan_cleanup if tibetan_str.blank?
          elsif relationship_system_str=='thl.ext.wyl.translit'
            wylie_str = name_str if wylie_str.blank?
          elsif relationship_system_str=='thl.simple.transcrip'
            phonetic_str = name_str if phonetic_str.blank?
          end
        end
        self.main_names = { tibetan: tibetan_str, wylie: wylie_str, phonetic: phonetic_str }
      when 'new.alpha'
        deva_str = nil
        latin_str = nil
        1.upto(2) do |i|
          name_tag = "#{i}.feature_names"
          name_str = self.fields.delete("#{name_tag}.name")
          writing_system_str = self.fields.delete("#{i}.writing_systems.code")
          relationship_system_str = self.fields.delete("#{i}.feature_name_relations.relationship.code")
          if writing_system_str=='deva'
            deva_str = name_str.strip if deva_str.blank?
          elsif relationship_system_str=='indo.standard.translit'
            latin_str = name_str.strip if latin_str.blank?
          end
        end
        self.main_names = { deva: deva_str, latin: latin_str }
      end
    end
    
    def set_up_main_names_for_new_or_blank_feature
      @relation_type ||= FeatureRelationType.get_by_code('heads')
      Rails.cache.delete("features/current_roots/#{self.perspective.id}")
      names_hash = self.main_names
      case self.perspective.code
      when 'tib.alpha'
        parent = TibetanTermsService.recursive_trunk_for(names_hash[:tibetan])
        if parent.ancestors_by_perspective(self.perspective).count != 2
          self.say "There is a problem for term: #{names_hash[:tibetan]} with calculated parent: #{parent.pid} in herarchy. Skipping term creation."
          return
        end
        attrs = { level_subject_id: Feature::BOD_EXPRESSION_SUBJECT_ID, tibetan: names_hash[:tibetan], wylie: names_hash[:wylie], phonetic: names_hash[:phonetic] }
        if self.feature.nil?
          self.feature = TibetanTermsService.add_term(**attrs)
        else
          attrs[:fid] = self.feature.fid
          TibetanTermsService.add_term(**attrs)
        end
        FeatureRelation.create!(child_node: self.feature, parent_node: parent, perspective: self.perspective, feature_relation_type: @relation_type)
        if self.last_parent.nil?
          self.last_parent = parent
        elsif self.last_parent != parent
          reposition_parent
          self.last_parent = parent
        end
      when 'new.alpha'
        parent = NewariTermsService.recursive_trunk_for(names_hash[:deva])
        if parent.ancestors_by_perspective(self.perspective).count != 2
          self.say "There is a problem for term: #{names_hash[:deva]} with calculated parent: #{parent.pid} in herarchy. Skipping term creation."
          return
        end
        attrs = { level_subject_id: Feature::NEW_EXPRESSION_SUBJECT_ID, deva: names_hash[:deva], latin: names_hash[:latin] }
        if self.feature.nil?
          self.feature = NewariTermsService.add_term(**attrs)
        else
          attrs[:fid] = self.feature.fid
          NewariTermsService.add_term(**attrs)
        end
        FeatureRelation.create!(child_node: self.feature, parent_node: parent, perspective: self.perspective, feature_relation_type: @relation_type)
        if self.last_parent.nil?
          self.last_parent = parent
        elsif self.last_parent != parent
          reposition_parent
          self.last_parent = parent
        end
      end
    end
    
    def infer_feature
      names_hash = self.main_names
      case self.perspective.code
      when 'tib.alpha'
        self.feature = Feature.search_bod_expression(names_hash[:tibetan])
        if self.feature.nil?
          self.log.debug "Adding new term #{names_hash[:tibetan]}"
        end
      when 'new.alpha'
        self.feature = Feature.search_new_expression(names_hash[:deva])
        if self.feature.nil?
          self.log.debug "Adding new term #{names_hash[:deva]}"
        end
      end
    end
    
    def reposition_parent
      self.log.debug { "#{Time.now}: Repositioning parent #{self.last_parent.fid}." }
      ts = TibetanTermsService.new(self.last_parent)
      ts.reposition
    end
    
    # [i.]definitions:
    # delete, content, language.code/name
    # Additionally, optional column "i.definition_relations.parent_node" can be
    # used to establish name i as child of name j by simply specifying the name number.
    # The parent name has to precede the child name. If a parent column is specified,
    def process_definitions(total)
      definitions = self.feature.definitions
      definition = Array.new(total)
      0.upto(total) do |i|
        prefix = i>0 ? "#{i}.definitions" : 'definitions'
        definition_content = self.fields.delete("#{prefix}.content")
        if !definition_content.blank?
          # I am unclear about support of adding several citations to a single definition.
          #info_sources = {}
          #0.upto(4) do |j|
          #  info_prefix = j==0 ? prefix : "#{prefix}.#{j}"
          #  info_source = self.get_info_source(info_prefix)
          #  info_sources[info_prefix] = info_source if !info_source.nil?
          #end
          info_source = self.get_info_source(prefix)
          delete_definitions_str = self.fields.delete("#{prefix}.delete")
          delete_definitions = !delete_definitions_str.blank? && delete_definitions_str.downcase == 'yes'
          def_begining = definition_content[0...200]
          def_begining = def_begining.split("\n").first
          def_with_tags = '<p>' + def_begining
          definition[i] = definitions.find_by(["LEFT(content, #{def_begining.size}) = ? OR LEFT(content, #{def_with_tags.size}) = ?", def_begining, def_with_tags]) # find_by(content: definition_content)
          if !definition[i].nil?
            citation = definition[i].citations.order(:created_at).first
            if !citation.nil? && info_source==citation.info_source
              if delete_definitions
                definition[i].destroy
                next
              end
            else #!info_sources.values.include?(citation.info_source)
              definition[i] = nil
            end
          else
            if delete_definitions
              self.say "Did not find definition for feature #{self.feature.pid} marked for deletion."
            end
          end
          language = Language.get_by_code_or_name(self.fields.delete("#{prefix}.languages.code"), self.fields.delete("#{prefix}.languages.name"))
          position = definitions.maximum(:position)
          position = position.nil? ? 1 : position + 1
          attributes = {content: definition_content, is_public: true, position: position}
          attributes[:language_id] = language.id if !language.nil?
          if definition[i].nil?
            if language.nil?
              self.say "Language needed to create definition for feature #{self.feature.pid}."
              definition[i] = nil
            else
              definition[i] = definitions.create(attributes)
            end
          else
            definition[i].update(attributes)
          end
          if !definition[i].nil?
            self.spreadsheet.imports.create(item: definition[i]) if definition[i].imports.find_by(spreadsheet_id: self.spreadsheet.id).nil?
            0.upto(4) do |j|
              info_prefix = j==0 ? prefix : "#{prefix}.#{j}"
              self.add_note(info_prefix, definition[i])
            end
            self.process_info_source(prefix, definition[i], info_source)
            #info_sources.each{ |prefix, info_source| self.process_info_source(prefix, definition[i], info_source) }
            parent_node_str = self.fields.delete("#{i}.definition_relations.parent_node")
            if !parent_node_str.blank?
              parent_position = parent_node_str.to_i
              parent_node = definition[parent_position]
              if parent_node.nil?
                self.say "Parent definition #{parent_position} of definition #{i} for feature #{self.feature.pid} not found."
              else
                relation = definition[i].parent_relations.find_by(parent_node_id: parent_node.id)
                if relation.nil?
                  relation = definition[i].parent_relations.create(parent_node_id: parent_node.id)
                  self.say "Relation between definitions #{i} and #{parent_position} for feature #{self.feature.pid} could not be saved." if relation.nil?
                end
              end
            end
            self.process_model_sentences(definition[i], prefix, 4)
          end
        end
      end
    end
    
    # [i.]translations:
    # content, language.code/name
    def process_translations(total)
      translations = self.feature.translation_equivalents
      definition = Array.new(total)
      0.upto(total) do |i|
        prefix = i>0 ? "#{i}.translations" : 'translations'
        translation_content = self.fields.delete("#{prefix}.content")
        if !translation_content.blank?
          info_sources = {}
          0.upto(4) do |j|
            info_prefix = j==0 ? prefix : "#{prefix}.#{j}"
            info_source = self.get_info_source(info_prefix)
            info_sources[info_prefix] = info_source if !info_source.nil?
          end
          translation_content.strip!
          next if translation_content.blank?
          language = Language.get_by_code_or_name(self.fields.delete("#{prefix}.languages.code"), self.fields.delete("#{prefix}.languages.name"))
          attributes = { content: translation_content }
          attributes[:language_id] = language.id if !language.nil?
          translation = translations.where(attributes).first
          if translation.nil?
            if language.nil?
              self.say "Language needed to create a translation for feature #{self.feature.pid}."
              translation = nil
            else
              translation = translations.create(attributes)
            end
          end
          if !translation.nil?
            self.spreadsheet.imports.create(item: translation) if translation.imports.find_by(spreadsheet_id: self.spreadsheet.id).nil?
            info_sources.each{ |prefix, info_source| self.process_info_source(prefix, translation, info_source) }
          end
        end
      end
    end
    
    # [i].definitions.[j].model_sentence
    def process_model_sentences(definition, prefix, n)
      sentences = definition.model_sentences
      0.upto(n) do |j|
        sentence_tag = j>0 ? "#{prefix}.#{j}.model_sentence" : "#{prefix}.model_sentence"
        sentence_content = self.fields.delete(sentence_tag)
        if !sentence_content.blank?
          sentence_html = "<p>#{sentence_content.strip}</p>"
          conditions = {content: sentence_html}
          sentence = sentences.find_by(conditions)
          if sentence.nil?
            sentence = sentences.create(conditions)
            if sentence.id.nil?
              self.say "Sentence #{sentence_content} not saved for definition #{definition.id}.- #{sentence.errors.messages}"
              next
            else
              self.spreadsheet.imports.create(item: sentence) if sentence.imports.find_by(spreadsheet_id: self.spreadsheet.id).nil?
            end
          else
            self.say "Sentence #{sentence_content} already imported for definition #{definition.id}."
          end
        end
      end
    end
    
    def process_kmaps(n)
      # Now deal with i.kmaps.id
      subject_term_associations = self.feature.subject_term_associations
      delete_kmaps = self.fields.delete('kmaps.delete')
      subject_term_associations.clear if !delete_kmaps.blank? && delete_kmaps.downcase == 'yes'
      1.upto(n) do |i|
        kmap_prefix = "#{i}.kmaps"
        kmap_str = self.fields.delete("#{kmap_prefix}.id")
        next if kmap_str.blank?
        kmap = SubjectsIntegration::Feature.find(kmap_str.scan(/\d+/).first.to_i)
        if kmap.nil?
          self.say "Could find kmap #{kmap_str} for term #{self.feature.pid}."
          next
        end
        conditions = { subject_id: kmap.id, branch_id: kmap.parents.first.id }
        subject_term_association = subject_term_associations.find_by(conditions)
        next if !subject_term_association.nil?
        subject_term_association = subject_term_associations.create(conditions)
        if subject_term_association.nil?
          self.say "Could create the association between subject kmap #{kmap_str} and term #{self.feature.pid}."
          next
        end
        self.spreadsheet.imports.create(item: subject_term_association) if subject_term_association.imports.find_by(spreadsheet_id: self.spreadsheet.id).nil?
        0.upto(3) do |j|
          prefix = j==0 ? kmap_prefix : "#{kmap_prefix}.#{j}"
          self.add_date(prefix, subject_term_association)
          self.add_note(prefix, subject_term_association)
          self.add_info_source(prefix, subject_term_association)
        end
      end
    end
  end
end
