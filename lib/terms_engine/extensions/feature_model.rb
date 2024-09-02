module TermsEngine
  module Extension
    module FeatureModel
      extend ActiveSupport::Concern
      include TermsEngine::HasPassages

      included do
        BOD_PHONEME_SUBJECT_ID = 9310
        BOD_LETTER_SUBJECT_ID = 9311
        BOD_NAME_SUBJECT_ID = 9312
        BOD_PHRASE_SUBJECT_ID = 9314
        BOD_EXPRESSION_SUBJECT_ID = 9315

        ENG_PHONEME_SUBJECT_ID = 9666
        ENG_LETTER_SUBJECT_ID = 9667
        ENG_WORD_SUBJECT_ID = 9668
        ENG_PHRASE_SUBJECT_ID = 9669
        
        NEW_PHONEME_SUBJECT_ID = 10522
        NEW_LETTER_SUBJECT_ID = 10523
        NEW_PLACE_HOLDER_SUBJECT_ID = 10524
        NEW_EXPRESSION_SUBJECT_ID = 10525
        
        has_many :definition_associations, as: :associated, dependent: :destroy
        has_many :etymologies, as: :context, dependent: :destroy
        has_many :model_sentences, as: :context, dependent: :destroy
        has_many :phoneme_term_associations, dependent: :destroy
        has_many :non_phoneme_term_associations, dependent: :destroy
        has_many :recordings, dependent: :destroy do
          def corrupted
            self.select{ |r| r.corrupted? }
          end
        end
        has_many :subject_term_associations, dependent: :destroy
        has_many :translation_equivalents, dependent: :destroy
        has_one  :enumeration, dependent: :destroy
        
        # This fetches root *Definitions* (definitions that don't have parents),
        # within the scope of the current feature
        has_many :definitions, dependent: :destroy do
          #
          #
          #
          def roots
            # proxy_target, proxy_owner, proxy_reflection - See Rails "Association Extensions"
            pa = proxy_association
            pa.reflection.class_name.constantize.roots.where('definitions.feature_id' => pa.owner.id).order(:position) #.sort !!! See the FeatureName.<=> method
          end
          
          def recursive_roots_with_path
            res = []
            self.roots.order('position').where(is_public: true).collect{ |r| res += r.recursive_roots_with_path }
            res
          end

          def all_definitions
            if @all_definitions.nil?
              definitions = self.roots
              standard_definitions = []
              legacy_definitions = {}
              in_house_definitions = {}
              definitions.each do |d|
                citation = d.non_standard_citations.first
                #citations = d.citations.where(info_source_type: InfoSource.model_name.name)
                if citation.nil?
                  standard_definitions << d
                else
                  info_source = citation.info_source
                  source_id = info_source.id
                  if info_source.processed?
                    in_house_definitions[source_id] ||= []
                    in_house_definitions[source_id] << d
                  else
                    legacy_definitions[source_id] ||= []
                    legacy_definitions[source_id] << d
                  end
                end
              end
              @all_definitions = { standard_definitions: standard_definitions, in_house_definitions: in_house_definitions, legacy_definitions: legacy_definitions }
            end
            @all_definitions
          end
          
          def standard_definitions
            all_definitions[:standard_definitions]
          end
          
          def in_house_definitions_by_info_source
            all_definitions[:in_house_definitions]
          end

          def legacy_definitions_by_info_source
            all_definitions[:legacy_definitions]
          end
        end
      end
      
      def legacy_relations(info_source)
        self.all_relations.reject{ |r| r.non_standard_citations.where(info_source: info_source).first.nil? }
      end
      
      def legacy_parent_relations(info_source)
        self.all_parent_relations.reject{ |r| r.non_standard_citations.where(info_source: info_source).first.nil? }
      end
      
      def legacy_child_relations(info_source)
        self.all_child_relations.reject{ |r| r.non_standard_citations.where(info_source: info_source).first.nil? }
      end
      
      def legacy_relations_by_type(info_source)
        hash = {}
        legacy_parent_relations(info_source).each do |r|
          rt = r.feature_relation_type
          f = r.parent_node
          if rt.is_symmetric?
            if hash[rt.label].nil?
              hash[rt.label] = [f]
            else
              hash[rt.label] << f
            end
          else
            if hash[rt.asymmetric_label].nil?
              hash[rt.asymmetric_label] = [f]
            else
              hash[rt.asymmetric_label] << f
            end
          end
        end
        legacy_child_relations(info_source).each do |r|
          f = r.child_node
          rt = r.feature_relation_type
          if hash[rt.label].nil?
            hash[rt.label] = [f]
          else
            hash[rt.label] << f
          end
        end
        return hash
      end
      
      def pid
        "T#{self.fid}"
      end
      
      def is_phoneme?(phoneme_id_or_array)
        !self.phoneme_term_associations.where(subject_id: phoneme_id_or_array).first.nil?
      end
      
      def phonemes
        self.phoneme_term_associations.collect(&:subject)
      end

      def perspective_by_name
          Perspective.get_by_language_code(self.names.first.language.code)
      end
      
      def document_for_rsolr
        name = self.names.first
        if name.nil?
          per = Perspective.get_by_code(KmapsEngine::ApplicationSettings.default_perspective_code)
        else
          per = self.perspective_by_name
          per = Perspective.get_by_code(KmapsEngine::ApplicationSettings.default_perspective_code) if per.nil?
        end
        v = View.get_by_code(KmapsEngine::ApplicationSettings.default_view_code)
        prefix = "related_#{Feature.uid_prefix}"
        child_documents = self.all_parent_relations.collect do |pr|
          parent_node = pr.parent_node
          name = parent_node.prioritized_name(v)
          name_str = name.nil? ? nil : name.name
          relation_type = pr.feature_relation_type
          cd = { id: "#{self.uid}_#{relation_type.code}_#{parent_node.fid}",
            related_uid_s: parent_node.uid,
            origin_uid_s: self.uid,
            block_child_type: [prefix],
            "#{prefix}_id_s" => "#{Feature.uid_prefix}-#{parent_node.fid}",
            "#{prefix}_header_s" => name_str,
            "#{prefix}_path_s" => parent_node.closest_ancestors_by_perspective(per).collect(&:fid).join('/'),
            "#{prefix}_relation_label_s" => relation_type.is_symmetric ? relation_type.label : relation_type.asymmetric_label,
            "#{prefix}_relation_code_s" => relation_type.code,
            related_kmaps_node_type: 'parent',
            block_type: ['child']
          }
          citations = pr.standard_citations
          p_rel_citation_references = citations.collect { |c| c.bibliographic_reference }
          cd["#{prefix}_relation_citation_references_ss"] = p_rel_citation_references if !p_rel_citation_references.blank?
          citations.each{ |ci| ci.rsolr_document_tags_for_notes(cd, "#{prefix}_relation") }
          info_source = pr.non_standard_citations.collect(&:info_source).first
          cd["#{prefix}_relation_source_code_s"] = info_source.code if !info_source.nil?
          time_units = pr.time_units_ordered_by_date.collect { |t| t.to_s }
          cd["#{prefix}_relation_time_units_ss"] = time_units if !time_units.blank?
          pr.notes.each { |n| n.rsolr_document_tags(cd, prefix) }
          subject_associations = parent_node.subject_term_associations
          related_branches = subject_associations.select(:branch_id).distinct.collect(&:branch_id)
          related_branches.each do |branch_id|
            branch = SubjectsIntegration::Feature.find(branch_id)
            cd["#{prefix}_branch_#{branch.uid}_header_s"] = branch.header
            headers = []
            uids = []
            subject_associations.where(branch_id: branch_id).each do |association|
              subject = SubjectsIntegration::Feature.find(association.subject_id)
              uids << subject.uid
              headers << subject.header
            end
            cd["#{prefix}_branch_#{branch.uid}_#{SubjectsIntegration::Feature.uid_prefix}_headers_t"] = headers
            cd["#{prefix}_branch_#{branch.uid}_#{SubjectsIntegration::Feature.uid_prefix}_uids_t"] = uids
          end
          cd
        end
        child_documents = child_documents + self.all_child_relations.collect do |pr|
          child_node = pr.child_node
          name = child_node.prioritized_name(v)
          name_str = name.nil? ? nil : name.name
          relation_type = pr.feature_relation_type
          code = relation_type.is_symmetric ? relation_type.code : relation_type.asymmetric_code
          cd =
          { id: "#{self.uid}_#{code}_#{child_node.fid}",
            related_uid_s: child_node.uid,
            origin_uid_s: self.uid,
            block_child_type: [prefix],
            "#{prefix}_id_s" => "#{Feature.uid_prefix}-#{child_node.fid}",
            "#{prefix}_header_s" => name_str,
            "#{prefix}_path_s" => child_node.closest_ancestors_by_perspective(per).collect(&:fid).join('/'),
            "#{prefix}_relation_label_s" => relation_type.label,
            "#{prefix}_relation_code_s" => code,
            related_kmaps_node_type: 'child',
            block_type: ['child']
          }
          citations = pr.standard_citations
          p_rel_citation_references = citations.collect { |c| c.bibliographic_reference }
          cd["#{prefix}_relation_citation_references_ss"] = p_rel_citation_references if !p_rel_citation_references.blank?
          citations.each{ |ci| ci.rsolr_document_tags_for_notes(cd, "#{prefix}_relation") }
          info_source = pr.non_standard_citations.collect(&:info_source).first
          cd["#{prefix}_relation_source_code_s"] = info_source.code if !info_source.nil?
          time_units = pr.time_units_ordered_by_date.collect { |t| t.to_s }
          cd["#{prefix}_relation_time_units_ss"] = time_units if !time_units.blank?
          pr.notes.each { |n| n.rsolr_document_tags(cd, prefix) }
          subject_associations = child_node.subject_term_associations
          related_branches = subject_associations.select(:branch_id).distinct.collect(&:branch_id)
          related_branches.each do |branch_id|
            branch = SubjectsIntegration::Feature.find(branch_id)
            cd["#{prefix}_branch_#{branch.uid}_header_s"] = branch.header
            headers = []
            uids = []
            subject_associations.where(branch_id: branch_id).each do |association|
              subject = SubjectsIntegration::Feature.find(association.subject_id)
              uids << subject.uid
              headers << subject.header
            end
            cd["#{prefix}_branch_#{branch.uid}_#{SubjectsIntegration::Feature.uid_prefix}_headers_t"] = headers
            cd["#{prefix}_branch_#{branch.uid}_#{SubjectsIntegration::Feature.uid_prefix}_uids_t"] = uids
          end
          cd
        end
        def_prefix = "related_#{Definition.uid_prefix}"
        child_documents = child_documents + self.definitions.recursive_roots_with_path.collect do |dp|
          d = dp.first
          path = dp.second
          uid = "#{Definition.uid_prefix}-#{d.id}"
          cd =
          { id: "#{self.uid}_#{uid}",
            origin_uid_s: self.uid,
            block_child_type: ["related_definitions"],
            "#{def_prefix}_content_#{d.writing_system.code}u" => d.content,
            "#{def_prefix}_path_s" => path.join('/'),
            "#{def_prefix}_level_i" => path.size,
            "#{def_prefix}_language_s" => d.language.name,
            "#{def_prefix}_language_code_s" => d.language.code,
            "#{def_prefix}_etymologies_ss" => d.etymologies.collect(&:content),
            block_type: ['child']
          }
          author = d.author
          cd["#{def_prefix}_author_s"] = author.fullname if !author.nil?
          cd["#{def_prefix}_tense_s"] = d.tense if !d.tense.nil?
          d.etymologies.each do |de|
            etymology_prefix = "#{def_prefix}_etymology_#{de.id}"
            cd["#{etymology_prefix}_content_ss"] = de.content
            etymology_type = de.etymology_type_association
            subject = etymology_type.nil? ? nil : etymology_type.subject
            cd["#{etymology_prefix}_type_#{subject['uid']}_s"] = subject['header'] if !subject.nil?
            de.notes.each { |n| n.rsolr_document_tags(cd, etymology_prefix) }
          end
          d.passage_translations.each { |pt| pt.rsolr_document_tags(cd, def_prefix) }
          d.passages.each { |p| p.rsolr_document_tags(cd, def_prefix) }
          d.model_sentences.each do |s|
            cd["#{def_prefix}_model_sentence_#{s.id}_content_t"] = s.content
            s.translations do |t|
              cd["#{def_prefix}_model_sentence_#{s.id}_translation_#{t.language.code}_content_t"] = t.content
            end
          end
          citations = d.standard_citations
          citation_references = citations.collect { |c| c.bibliographic_reference }
          cd["#{def_prefix}_citation_references_ss"] = citation_references if !citation_references.blank?
          citations.each{ |ci| ci.rsolr_document_tags_for_notes(cd, def_prefix) }
          info_source = d.legacy_citations.collect(&:info_source).first
          cd["#{def_prefix}_source_code_s"] = info_source.code if !info_source.nil?
          info_source = d.in_house_citations.collect(&:info_source).first
          cd["#{def_prefix}_in_house_source_code_s"] = info_source.code if !info_source.nil?
          d.notes.each { |n| n.rsolr_document_tags(cd, def_prefix) }
          subject_associations = d.definition_subject_associations
          related_branches = subject_associations.select(:branch_id).distinct.collect(&:branch_id)
          related_branches.each do |branch_id|
            branch = SubjectsIntegration::Feature.find(branch_id)
            cd["#{def_prefix}_branch_#{branch.uid}_header_s"] = branch.header
            headers = []
            uids = []
            subject_associations.where(branch_id: branch_id).each do |association|
              subject = SubjectsIntegration::Feature.find(association.subject_id)
              uids << subject.uid
              headers << subject.header
            end
            cd["#{def_prefix}_branch_#{branch.uid}_#{SubjectsIntegration::Feature.uid_prefix}_headers_t"] = headers
            cd["#{def_prefix}_branch_#{branch.uid}_#{SubjectsIntegration::Feature.uid_prefix}_uids_t"] = uids
          end
          cd
        end
        child_documents = child_documents + self.recordings.reject{ |recording| recording.audio_file.blob.nil? }.collect do |recording|
          {id: "#{self.uid}_recording_#{recording.id}",
           block_child_type: ['terms_recording'],
           block_type: ['child'],
           recording_url: "#{TermsEngine::Configuration.server_url}#{Rails.application.routes.url_helpers.rails_blob_path(recording.audio_file, disposition: 'attachment', only_path: true)}",
           recording_dialect_s: recording.dialect['header'],
           recording_dialect_uid_s: recording.dialect['uid']
          }
        end
        subject_associations = self.subject_term_associations
        doc = { tree: Feature.uid_prefix,
                associated_subjects: subject_associations.collect{ |a| a.subject['header'] },
                associated_subject_ids: subject_associations.collect(&:subject_id),
                etymologies_ss: self.etymologies.collect(&:content),
                enumeration: self.enumeration&.value,
                block_type: ['parent'],
                '_childDocuments_'  => child_documents }
        if self.is_phoneme?(Feature::BOD_EXPRESSION_SUBJECT_ID)
          perspective = Perspective.get_by_code('tib.alpha')
          type = FeatureRelationType.get_by_code('heads')
          phrase = self.parent_relations.where(feature_relation_type: type, perspective: perspective).first.parent_node
          type = FeatureRelationType.get_by_code('is.beginning.of')
          letter = phrase.parent_relations.where(feature_relation_type: type, perspective: perspective).first.parent_node
          doc[:cascading_position_i] = letter.position * 1000 * 1000 + phrase.position * 1000 + self.position
        elsif self.is_phoneme?([Feature::ENG_WORD_SUBJECT_ID, Feature::ENG_PHRASE_SUBJECT_ID])
          perspective = Perspective.get_by_code('eng.alpha')
          type = FeatureRelationType.get_by_code('is.beginning.of')
          letter = self.parent_relations.where(feature_relation_type: type, perspective: perspective).first.parent_node
          doc[:cascading_position_i] = letter.position * 1000 + self.position
        elsif self.is_phoneme?(Feature::NEW_EXPRESSION_SUBJECT_ID)
          perspective = Perspective.get_by_code('new.alpha')
          type = FeatureRelationType.get_by_code('heads')
          phrase_relation = self.parent_relations.where(feature_relation_type: type, perspective: perspective).first
          if phrase_relation.nil?
            type = FeatureRelationType.get_by_code('is.beginning.of')
            letter = self.parent_relations.where(feature_relation_type: type, perspective: perspective).first.parent_node
            doc[:cascading_position_i] = letter.position * 1000 + self.position
          else
            phrase = phrase_relation.parent_node
            type = FeatureRelationType.get_by_code('is.beginning.of')
            letter = phrase.parent_relations.where(feature_relation_type: type, perspective: perspective).first.parent_node
            doc[:cascading_position_i] = letter.position * 1000 * 1000 + phrase.position * 1000 + self.position
          end
        end
        subject_associations.each do |sa|
          branch_prefix = "#{prefix}_branch_#{sa.branch_id}"
          subject_prefix = "#{branch_prefix}_#{SubjectsIntegration::Feature.uid_prefix}_#{sa.subject_id}"
          citations = sa.citations
          citation_references = citations.collect { |c| c.bibliographic_reference }
          doc["#{subject_prefix}_citation_references_ss"] = citation_references if !citation_references.blank?
          citations.each{ |ci| ci.rsolr_document_tags_for_notes(doc, subject_prefix) }
          time_units = sa.time_units_ordered_by_date.collect { |t| t.to_s }
          doc["#{subject_prefix}_time_units_ss"] = time_units if !time_units.blank?
          sa.notes.each { |n| n.rsolr_document_tags(doc, branch_prefix) }
        end
        self.etymologies.each do |e|
          etymology_prefix = "etymology_#{e.id}"
          doc["#{etymology_prefix}_content_s"] = e.content
          etymology_type = e.etymology_type_association
          subject = etymology_type.nil? ? nil : etymology_type.subject
          doc["#{etymology_prefix}_type_#{subject['uid']}_s"] = subject['header'] if !subject.nil?
          e.notes.each { |n| n.rsolr_document_tags(doc, etymology_prefix) }
          citations = e.citations
          citation_references = citations.collect { |c| c.bibliographic_reference }
          doc["#{etymology_prefix}_citation_references_ss"] = citation_references if !citation_references.blank?
          citations.each{ |ci| ci.rsolr_document_tags_for_notes(doc, etymology_prefix) }
        end
        for branch_id in subject_associations.select(:branch_id).distinct.collect(&:branch_id)
          associations = subject_associations.where(branch_id: branch_id)
          doc["associated_subject_#{branch_id}_ls"] = associations.collect(&:subject_id)
          doc["associated_subject_#{branch_id}_ss"] = associations.collect{ |a| a.subject['header'] }
        end
        self.passages.each do |p|
          p.rsolr_document_tags(doc)
        end
        self.translation_equivalents.each do |te|
          te.rsolr_document_tags(doc)
        end
        self.model_sentences.each do |s|
          doc["model_sentence_#{s.id}_content_t"] = s.content
        end
        doc
      end
      
      def calculate_prioritized_name(current_view)
        all_names = prioritized_names
        case current_view.code
        when 'roman.scholar'
          name = scholarly_prioritized_name(all_names)
        when 'pri.orig.sec.roman'
          name = tibetan_prioritized_name(all_names)
          name = FeatureExtensionForNamePositioning::HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('deva').id) if name.nil?
        end
        name || popular_prioritized_name(all_names)
      end
      
      def bod_expression?
        !self.subject_term_associations.where(branch_id: Feature::BOD_PHONEME_SUBJECT_ID, subject_id: Feature::BOD_EXPRESSION_SUBJECT_ID).first.nil?
      end
      
      module ClassMethods
        def corrupted
          ipc_reader, ipc_writer = IO.pipe('ASCII-8BIT')
          ipc_writer.set_encoding('ASCII-8BIT')
          n = Feature.count
          i = 0
          limit = 100
          corrupted = []
          while i<n
            sid = Spawnling.new(kill: true) do
              ipc_reader.close
              range = Feature.all.order(:fid).limit(limit).offset(i)
              new_corrupted = range.collect { |f| f.recordings.corrupted.collect{|r| r.id} }
              new_corrupted.reject! { |c| c.blank? }
              ipc_hash = {corrupted: new_corrupted }
              data = Marshal.dump(ipc_hash)
              ipc_writer.puts(data.length)
              ipc_writer.write(data)
              ipc_writer.flush
              ipc_writer.close
            end
            Spawnling.wait([sid])
            size = ipc_reader.gets
            data = ipc_reader.read(size.to_i)
            ipc_hash = Marshal.load(data)
            corrupted += ipc_hash[:corrupted]
            i += limit
          end
          ipc_writer.close
          return corrupted
        end
        
        def current_roots_by_perspective(current_perspective)
          feature_ids = Rails.cache.fetch("features/current_roots/#{current_perspective.id}", expires_in: 1.day) do
            self.where('features.is_blank' => false).scoping do
              self.roots.order(:position).select do |r|
                # if ANY of the child relations are current, return true to nab this Feature
                relations = r.child_relations
                (relations.empty? && (r.perspective_by_name == current_perspective)) || relations.any? {|cr| cr.perspective == current_perspective }
              end
            end.collect(&:id)
          end
          feature_ids.collect{ |fid| Feature.find(fid) }
        end

        def search_by_phoneme(name, phoneme_id)
          name = FeatureName.joins(feature: :subject_term_associations).where(name: name, 'subject_term_associations.subject_id' => Feature::BOD_EXPRESSION_SUBJECT_ID).first
          name.nil? ? nil : name.feature
          #name_position = names.find_index{ |n| n.feature.subject_term_associations.collect(&:subject_id).include? phoneme_id }
          #name_position.nil? ? nil : names[name_position].feature
        end

        def search_by_eng_phoneme(name, phoneme_id)
          names = FeatureName.where('lower(name) = ?', name.downcase).joins(feature: :subject_term_associations)
          name_position = names.find_index{ |n| n.feature.subject_term_associations.collect(&:subject_id).include? phoneme_id }
          name_position.nil? ? nil : names[name_position].feature
        end

        def search_by_excluding_phoneme(name, branch_id, phoneme_id)
          names = FeatureName.where('lower(name) = ?', name.downcase).joins(feature: :subject_term_associations)
          name_position = names.find_index do |n|
            !(n.feature.subject_term_associations.find_index { |a| a.branch_id == branch_id && a.subject_id != phoneme_id }).nil?
          end
          name_position.nil? ? nil : names[name_position].feature
        end

        def search_english_term(name)
          Feature.search_by_excluding_phoneme(name, ENG_PHONEME_SUBJECT_ID, ENG_LETTER_SUBJECT_ID)
        end
        
        def search_bod_expression(name_str)
          if name_str.is_tibetan_word?
            script = WritingSystem.get_by_code('tibt')
            name = FeatureName.joins(feature: :subject_term_associations).where(name: name_str, writing_system_id: script.id, 'subject_term_associations.branch_id' => Feature::BOD_PHONEME_SUBJECT_ID, 'subject_term_associations.subject_id' => Feature::BOD_EXPRESSION_SUBJECT_ID).first
          else
            script = WritingSystem.get_by_code('latin')
            o = OrthographicSystem.get_by_code('thl.ext.wyl.translit')
            name = FeatureName.joins(:parent_relations, feature: :subject_term_associations).where(name: name_str, writing_system_id: script.id, 'subject_term_associations.branch_id' => Feature::BOD_PHONEME_SUBJECT_ID, 'subject_term_associations.subject_id' => Feature::BOD_EXPRESSION_SUBJECT_ID, 'feature_name_relations.orthographic_system_id' => o.id).first
            if name.nil?
              last_char = name_str[name_str.size-1]
              if last_char != '/'
                if name_str.end_with?('ng')
                  name = FeatureName.joins(:parent_relations, feature: :subject_term_associations).where(name: "#{name_str} /", writing_system_id: script.id, 'subject_term_associations.branch_id' => Feature::BOD_PHONEME_SUBJECT_ID, 'subject_term_associations.subject_id' => Feature::BOD_EXPRESSION_SUBJECT_ID, 'feature_name_relations.orthographic_system_id' => o.id).first
                  name = FeatureName.joins(:parent_relations, feature: :subject_term_associations).where(name: "#{name_str}/", writing_system_id: script.id, 'subject_term_associations.branch_id' => Feature::BOD_PHONEME_SUBJECT_ID, 'subject_term_associations.subject_id' => Feature::BOD_EXPRESSION_SUBJECT_ID, 'feature_name_relations.orthographic_system_id' => o.id).first if name.nil?
                else
                  name = FeatureName.joins(:parent_relations, feature: :subject_term_associations).where(name: "#{name_str}/", writing_system_id: script.id, 'subject_term_associations.branch_id' => Feature::BOD_PHONEME_SUBJECT_ID, 'subject_term_associations.subject_id' => Feature::BOD_EXPRESSION_SUBJECT_ID, 'feature_name_relations.orthographic_system_id' => o.id).first if name.nil?
                end
              end
            end
          end
          name.nil? ? nil : name.feature
        end
        
        def search_new_expression(name_str)
          if name_str.is_devanagari_word?
            script = WritingSystem.get_by_code('deva')
            name = FeatureName.joins(feature: :subject_term_associations).where(name: name_str, writing_system_id: script.id, 'subject_term_associations.branch_id' => Feature::NEW_PHONEME_SUBJECT_ID, 'subject_term_associations.subject_id' => Feature::NEW_EXPRESSION_SUBJECT_ID).first
          else
            script = WritingSystem.get_by_code('latin')
            o = OrthographicSystem.get_by_code('indo.standard.translit')
            name = FeatureName.joins(:parent_relations, feature: :subject_term_associations).where(name: name_str, writing_system_id: script.id, 'subject_term_associations.branch_id' => Feature::NEW_PHONEME_SUBJECT_ID, 'subject_term_associations.subject_id' => Feature::NEW_EXPRESSION_SUBJECT_ID, 'feature_name_relations.orthographic_system_id' => o.id).first
          end
          name.nil? ? nil : name.feature
        end
        
        def solr_url
          URI.join(TermsResource.get_url, "solr/")
        end
      end
    end
  end
end
