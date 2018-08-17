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
    # i.geo_code_types.code/name, i.feature_geo_codes.geo_code_value, i.feature_geo_codes.info_source.id/code,
    # feature_relations.delete, [i.]feature_relations.related_feature.fid, [i.]feature_relations.type.code,
    # [i.]perspectives.code/name, feature_relations.replace
    # descriptions.delete, [i.]descriptions.title, [i.]descriptions.content, [i.]descriptions.author.fullname


    # Fields that accept time_units:
    # features, i.feature_names[.j], [i.]feature_types[.j], i.kmaps[.j], [i.]kXXX[.j], i.feature_geo_codes[.j], [i.]feature_relations[.j], [i.]shapes[.j]

    # time_units fields supported:
    # .time_units.[start.|end.]date, .time_units.[start.|end.]certainty_id, .time_units.season_id,
    # .time_units.calendar_id, .time_units.frequency_id

    # Fields that accept info_source:
    # [i.]feature_names[.j], [i.]feature_types[.j], i.feature_geo_codes[.j], [i.]kXXX[.j], i.kmaps[.j], [i.]feature_relations[.j], [i.]shapes[.j]

    # info_source fields:
    # .info_source.id/code, info_source.note
    # When info source is a document: .info_source[.i].volume, info_source[.i].pages
    # When info source is an online resource: .info_source[.i].path, .info_source[.i].name

    # Fields that accept note:
    # [i.]feature_names[.j], i.kmaps[.j], [i.]kXXX[.j], [i.]feature_types[.j], [i.]feature_relations[.j], [i.]shapes[.j], i.feature_geo_codes[.j]

    # Note fields:
    # .note

    def do_feature_import(filename, task_code)
      task = ImportationTask.find_by(task_code: task_code)
      task = ImportationTask.create(:task_code => task_code) if task.nil?
      self.spreadsheet = task.spreadsheets.find_by(filename: filename)
      self.spreadsheet = task.spreadsheets.create(:filename => filename, :imported_at => Time.now) if self.spreadsheet.nil?
      current = 0
      feature_ids_with_changed_relations = Array.new
      puts "#{Time.now}: Starting importation."
      CSV.foreach(filename, headers: true, col_sep: "\t") do |row|
        self.fields = row.to_hash.delete_if{ |key, value| value.blank? }
        current+=1
        next unless self.get_feature(current)
        self.process_feature
        self.process_names(44)
        self.process_geocodes(4)
        feature_ids_with_changed_relations += self.process_feature_relations(15)
        self.process_descriptions(3)
        self.process_captions(2)
        self.process_summaries(2)
        self.feature.update_attributes({:is_blank => false, :is_public => true})
        #rescue  Exception => e
        #  puts "Something went wrong with feature #{self.feature.pid}!"
        #  puts e.to_s
        #end
        if self.fields.empty?
          puts "#{Time.now}: #{self.feature.pid} processed."
        else
          puts "#{Time.now}: #{self.feature.pid}: the following fields have been ignored: #{self.fields.keys.join(', ')}"
        end
      end
      puts "Updating cache..."
      # running triggers on feature_relation
      feature_ids_with_changed_relations.each do |id| 
        feature = Feature.find(id)
        #this has to be added to places dictionary!!!
        #feature.update_cached_feature_relation_categories
        feature.update_hierarchy
      end
      puts "#{Time.now}: Importation done."
    end    
  end
end