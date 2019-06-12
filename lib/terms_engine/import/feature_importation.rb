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
    # [i.]definitions.content, [i.]definitions.languages.code/name
    
    # Fields that accept time_units:
    # features, i.feature_names[.j]

    # time_units fields supported:
    # .time_units.[start.|end.]date, .time_units.[start.|end.]certainty_id, .time_units.season_id,
    # .time_units.calendar_id, .time_units.frequency_id

    # Fields that accept info_source:
    # [i.]feature_names[.j], [i.]definitions[.j]

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
      ipc_reader, ipc_writer = IO.pipe('ASCII-8BIT')
      ipc_writer.set_encoding('ASCII-8BIT')
      puts "#{Time.now}: Processing features..."
      STDOUT.flush
      fids_to_reindex = Array.new
      while current<total
        limit = current + interval
        limit = total if limit > total
        limit = rows.size if limit > rows.size
        self.wait_if_business_hours(daylight)
        sid = Spawnling.new do
          begin
            self.log.debug { "#{Time.now}: Spawning sub-process #{Process.pid}." }
            ipc_reader.close
            fids_in_spawn = []
            for i in current...limit
              row = rows[i]
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
                self.process_names(44)
              else
                fids_in_spawn += current_fids_to_reindex
                fids_in_spawn.uniq!
              end
              process_definitions(1)
              self.feature.update_attributes({:is_blank => false, :is_public => true})
              self.progress_bar(num: i, total: total, current: self.feature.pid)
              if self.fields.empty?
                self.log.debug { "#{Time.now}: #{self.feature.pid} processed." }
              else
                self.log.warn { "#{Time.now}: #{self.feature.pid}: the following fields have been ignored: #{self.fields.keys.join(', ')}" }
              end
            end
            ipc_hash = { for_reindexing: fids_in_spawn, bar: self.bar, num_errors: self.num_errors, valid_point: self.valid_point }
            data = Marshal.dump(ipc_hash)
            ipc_writer.puts(data.length)
            ipc_writer.write(data)
            ipc_writer.flush
            ipc_writer.close
          rescue Exception => e
            STDOUT.flush
            self.log.fatal { "#{Time.now}: An error occured when processing #{Process.pid}:" }
            self.log.fatal { e.message }
            self.log.fatal { e.backtrace.join("\n") }
          end
        end
        Spawnling.wait([sid])
        size = ipc_reader.gets
        data = ipc_reader.read(size.to_i)
        ipc_hash = Marshal.load(data)
        fids_in_spawn = ipc_hash[:for_reindexing]
        fids_to_reindex += fids_in_spawn
        fids_to_reindex.uniq!
        self.update_progress_bar(bar: ipc_hash[:bar], num_errors: ipc_hash[:num_errors], valid_point: ipc_hash[:valid_point])
        current = limit
      end
      ipc_writer.close
      KmapsEngine::FlareUtils.new(self.log).reindex_fids(fids_to_reindex, daylight)
    end
    
    def infer_or_create_feature
      @tib_alpha ||= Perspective.get_by_code('tib.alpha')
      @relation_type ||= FeatureRelationType.get_by_code('is.beginning.of')
      
      tibetan_str = nil
      wylie_str = nil
      phonetic_str = nil
      1.upto(3) do |i|
        name_tag = "#{i}.feature_names"
        name_str = self.fields["#{name_tag}.name"]
        writing_system_str = self.fields["#{i}.writing_systems.code"]
        relationship_system_str = self.fields["#{i}.feature_name_relations.relationship.code"]
        if writing_system_str=='tibt'
          tibetan_str = name_str.tibetan_cleanup if tibetan_str.blank?
        elsif relationship_system_str=='thl.ext.wyl.translit'
          wylie_str = name_str if wylie_str.blank?
        elsif relationship_system_str=='thl.simple.transcrip'
          phonetic_str = name_str if phonetic_str.blank?
        end
      end
      self.feature = Feature.search_expression(tibetan_str)
      if self.feature.nil?
        self.log.debug "Adding new term #{tibetan_str}"
        parent = TermsService.recursive_trunk_for(tibetan_str)
        if parent.ancestors_by_perspective(@tib_alpha).count != 2
          self.say "There is a problem for term: #{current_entry} with calculated parent: #{parent.pid} in herarchy. Skipping term creation."
          return nil
        end
        self.feature = TermsService.add_term(Feature::EXPRESSION_SUBJECT_ID, tibetan_str, wylie_str, phonetic_str)
        FeatureRelation.create!(child_node: self.feature, parent_node: parent, perspective: @tib_alpha, feature_relation_type: @relation_type)
        ts = TermsService.new(parent)
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
    def process_definitions(n)
      definitions = self.feature.definitions
      0.upto(n) do |i|
        prefix = i>0 ? "#{i}.definitions" : 'definitions'
        definition_content = self.fields.delete("#{prefix}.content")
        if !definition_content.blank?
          definition = definitions.find_by(['LEFT(content, 200) = ?', definition_content[0...200]]) # find_by(content: definition_content)
          language = Language.get_by_code_or_name(self.fields.delete("#{prefix}.languages.code"), self.fields.delete("#{prefix}.languages.name"))
          position = definitions.maximum(:position)
          position = position.nil? ? 1 : position + 1
          attributes = {content: definition_content, is_public: true, position: position}
          attributes[:language_id] = language.id if !language.nil?
          if definition.nil?
            if language.nil?
              self.say "Language needed to create definition for feature #{self.feature.pid}."
              definition = nil
            else
              definition = definitions.create(attributes)
            end
          else
            definition.update_attributes(attributes)
          end
          if !definition.nil?
            self.spreadsheet.imports.create(item: definition) if definition.imports.find_by(spreadsheet_id: self.spreadsheet.id).nil?
            0.upto(4) do |j|
              info_prefix = j==0 ? prefix : "#{prefix}.#{j}"
              self.add_info_source(info_prefix, definition)
            end
          end
        end
      end
    end
  end
end