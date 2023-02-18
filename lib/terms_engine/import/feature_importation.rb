require 'kmaps_engine/import/feature_importation'

module TermsEngine
  class FeatureImportation < KmapsEngine::FeatureImportation
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

    def do_feature_import(filename:, task_code:, daylight:)
      puts "#{Time.now}: Starting importation."
      task = ImportationTask.find_by(task_code: task_code)
      task = ImportationTask.create(:task_code => task_code) if task.nil?
      self.log.debug { "#{Time.now}: Starting importation." }
      self.spreadsheet = task.spreadsheets.find_by(filename: filename)
      self.spreadsheet = task.spreadsheets.create(:filename => filename, :imported_at => Time.now) if self.spreadsheet.nil?
      interval = 100
      rows = CSV.read(filename, headers: true, col_sep: "\t")
      current = 0
      total = rows.size
      puts "#{Time.now}: Processing features..."
      fids_to_reindex = Array.new
      while current<total
        self.wait_if_business_hours(daylight)
        begin
          row = rows[current]
          self.fields = row.to_hash.delete_if{ |key, value| value.blank? }
          current+=1
          if !self.fields['features.fid'].blank?
            next unless self.get_feature(current)
            current_fids_to_reindex = nil
          else
            current_fids_to_reindex = self.infer_or_create_feature
          end
          self.process_feature
          if current_fids_to_reindex.nil?
            if self.process_names(44)
              fids_to_reindex << self.feature.fid
            end
          else
            fids_to_reindex += current_fids_to_reindex
          end
          process_definitions(16)
          process_translations(64)
          process_feature_relations(0)
          self.feature.update_attributes(is_blank: false, is_public: true, skip_update: true)
          self.progress_bar(num: current, total: total, current: self.feature.pid)
          if self.fields.empty?
            self.log.debug { "#{Time.now}: #{self.feature.pid} processed." }
          else
            self.log.warn { "#{Time.now}: #{self.feature.pid}: the following fields have been ignored: #{self.fields.keys.join(', ')}" }
          end
        rescue Exception => e
          STDOUT.flush
          self.log.fatal { "#{Time.now}: An error occured:" }
          self.log.fatal { e.message }
          self.log.fatal { e.backtrace.join("\n") }
        end
        fids_to_reindex.uniq!
        self.update_progress_bar(bar: self.bar, num_errors: self.num_errors, valid_point: self.valid_point)
      end
      KmapsEngine::FlareUtils.new(self.log).reindex_fids(fids_to_reindex, daylight)
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
    
    def infer_or_create_feature
      @tib_alpha ||= Perspective.get_by_code('tib.alpha')
      @relation_type ||= FeatureRelationType.get_by_code('heads')
      
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
      self.feature = Feature.search_bod_expression(tibetan_str)
      if self.feature.nil?
        self.log.debug "Adding new term #{tibetan_str}"
        parent = TibetanTermsService.recursive_trunk_for(tibetan_str)
        if parent.ancestors_by_perspective(@tib_alpha).count != 2
          self.say "There is a problem for term: #{current_entry} with calculated parent: #{parent.pid} in herarchy. Skipping term creation."
          return nil
        end
        self.feature = TibetanTermsService.add_term(Feature::BOD_EXPRESSION_SUBJECT_ID, tibetan_str, wylie_str, phonetic_str)
        FeatureRelation.create!(child_node: self.feature, parent_node: parent, perspective: @tib_alpha, feature_relation_type: @relation_type)
        ts = TibetanTermsService.new(parent)
        ts.reposition
        self.feature.reload
        position = self.feature.position
        return [parent.fid, self.feature.fid] + parent.children.where('position > ?', position).collect(&:fid)
      else
        return [self.feature.fid]
      end
    end
    
    # [i.]definitions:
    # content, language.code/name
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
          info_sources = {}
          0.upto(4) do |j|
            info_prefix = j==0 ? prefix : "#{prefix}.#{j}"
            info_source = self.get_info_source(info_prefix)
            info_sources[info_prefix] = info_source if !info_source.nil?
          end
          definition[i] = definitions.find_by(['LEFT(content, 200) = ?', definition_content[0...200]]) # find_by(content: definition_content)
          if !definition[i].nil?
            citation = definition[i].citations.order(:created_at).first
            definition[i] = nil if !info_sources.values.include?(citation.info_source)
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
            definition[i].update_attributes(attributes)
          end
          if !definition[i].nil?
            self.spreadsheet.imports.create(item: definition[i]) if definition[i].imports.find_by(spreadsheet_id: self.spreadsheet.id).nil?
            0.upto(4) do |j|
              info_prefix = j==0 ? prefix : "#{prefix}.#{j}"
              self.add_note(info_prefix, definition[i])
            end
            info_sources.each{ |prefix, info_source| self.process_info_source(prefix, definition[i], info_source) }
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
  end
end
