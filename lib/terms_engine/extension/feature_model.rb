module TermsEngine
  module Extension
    module FeatureModel
      extend ActiveSupport::Concern
      include KmapsEngine::HasPassages

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
        
        has_many :subject_term_associations, dependent: :destroy
        has_many :phoneme_term_associations
        has_many :recordings, dependent: :destroy
        has_many :etymologies, as: :context, dependent: :destroy
        
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
              definitions = self.roots.includes(:legacy_citations)
              in_house_definitions = []
              legacy_definitions = {}
              definitions.each do |d|
                citations = d.legacy_citations
                #citations = d.citations.where(info_source_type: InfoSource.model_name.name)
                if citations.empty?
                  in_house_definitions << d
                else
                  citation_id = citations.first.info_source_id
                  legacy_definitions[citation_id] ||= []
                  legacy_definitions[citation_id] << d
                  #legacy_definitions << d
                end
              end
              @all_definitions = { in_house_definitions: in_house_definitions, legacy_definitions: legacy_definitions }
            end
            @all_definitions
          end

          def in_house_definitions
            all_definitions[:in_house_definitions]
          end

          def legacy_definitions_by_info_source
            all_definitions[:legacy_definitions]
          end
        end
      end
      
      def pid
        "T#{self.fid}"
      end
      
      def phonemes
        self.phoneme_term_associations.collect(&:subject)
      end

      def perspective_by_name
          Perspective.get_by_language_code(self.names.first.language.code)
      end
      
      def document_for_rsolr
        name = self.name.first
        if name.nil?
          per = Perspective.get_by_code(KmapsEngine::ApplicationSettings.default_perspective_code)
        else
          per = self.perspective_by_name
        end
        v = View.get_by_code(KmapsEngine::ApplicationSettings.default_view_code)
        child_documents = self.all_parent_relations.collect do |pr|
          parent_node = pr.parent_node
          name = parent_node.prioritized_name(v)
          name_str = name.nil? ? nil : name.name
          parent = pr.parent_node
          relation_type = pr.feature_relation_type
          cd =
          { id: "#{self.uid}_#{pr.feature_relation_type.code}_#{parent.fid}",
            related_uid_s: parent.uid,
            origin_uid_s: self.uid,
            block_child_type: ["related_#{Feature.uid_prefix}"],
            "related_#{Feature.uid_prefix}_id_s" => "#{Feature.uid_prefix}-#{parent.fid}",
            "related_#{Feature.uid_prefix}_header_s" => name_str,
            "related_#{Feature.uid_prefix}_path_s" => parent_node.closest_ancestors_by_perspective(per).collect(&:fid).join('/'),
            "related_#{Feature.uid_prefix}_relation_label_s" => relation_type.is_symmetric ? relation_type.label : relation_type.asymmetric_label,
            "related_#{Feature.uid_prefix}_relation_code_s" => relation_type.code,
            related_kmaps_node_type: 'parent',
            block_type: ['child']
          }
          p_rel_citation_references = pr.citations.collect { |c| c.info_source.bibliographic_reference }
          cd["related_#{Feature.uid_prefix}_relation_citation_references_ss"] = p_rel_citation_references if !p_rel_citation_references.blank?
          subject_associations = parent_node.subject_term_associations
          related_branches = subject_associations.select(:branch_id).distinct.collect(&:branch_id)
          related_branches.each do |branch_id|
            branch = SubjectsIntegration::Feature.find(branch_id)
            cd["related_#{Feature.uid_prefix}_branch_#{branch.uid}_header_s"] = branch.header
            headers = []
            uids = []
            subject_associations.where(branch_id: branch_id).each do |association|
              subject = SubjectsIntegration::Feature.find(association.subject_id)
              uids << subject.uid
              headers << subject.header
            end
            cd["related_#{Feature.uid_prefix}_branch_#{branch.uid}_#{SubjectsIntegration::Feature.uid_prefix}_headers_t"] = headers
            cd["related_#{Feature.uid_prefix}_branch_#{branch.uid}_#{SubjectsIntegration::Feature.uid_prefix}_uids_t"] = uids
          end
          cd
        end
        child_documents = child_documents + self.all_child_relations.collect do |pr|
          child_node = pr.child_node
          name = child_node.prioritized_name(v)
          name_str = name.nil? ? nil : name.name
          child = pr.child_node
          relation_type = pr.feature_relation_type
          cd =
          { id: "#{self.uid}_#{pr.feature_relation_type.asymmetric_code}_#{child.fid}",
            related_uid_s: child.uid,
            origin_uid_s: self.uid,
            block_child_type: ["related_#{Feature.uid_prefix}"],
            "related_#{Feature.uid_prefix}_id_s" => "#{Feature.uid_prefix}-#{child.fid}",
            "related_#{Feature.uid_prefix}_header_s" => name_str,
            "related_#{Feature.uid_prefix}_path_s" => child_node.closest_ancestors_by_perspective(per).collect(&:fid).join('/'),
            "related_#{Feature.uid_prefix}_relation_label_s" => relation_type.label,
            "related_#{Feature.uid_prefix}_relation_code_s" => relation_type.is_symmetric ? relation_type.code : relation_type.asymmetric_code,
            related_kmaps_node_type: 'child',
            block_type: ['child']
          }
          p_rel_citation_references = pr.citations.collect { |c| c.info_source.bibliographic_reference }
          cd["related_#{Feature.uid_prefix}_relation_citation_references_ss"] = p_rel_citation_references if !p_rel_citation_references.blank?
          subject_associations = child_node.subject_term_associations
          related_branches = subject_associations.select(:branch_id).distinct.collect(&:branch_id)
          related_branches.each do |branch_id|
            branch = SubjectsIntegration::Feature.find(branch_id)
            cd["related_#{Feature.uid_prefix}_branch_#{branch.uid}_header_s"] = branch.header
            headers = []
            uids = []
            subject_associations.where(branch_id: branch_id).each do |association|
              subject = SubjectsIntegration::Feature.find(association.subject_id)
              uids << subject.uid
              headers << subject.header
            end
            cd["related_#{Feature.uid_prefix}_branch_#{branch.uid}_#{SubjectsIntegration::Feature.uid_prefix}_headers_t"] = headers
            cd["related_#{Feature.uid_prefix}_branch_#{branch.uid}_#{SubjectsIntegration::Feature.uid_prefix}_uids_t"] = uids
          end
          cd
        end
        child_documents = child_documents + self.definitions.recursive_roots_with_path.collect do |dp|
          d = dp.first
          path = dp.second
          uid = "#{Definition.uid_prefix}-#{d.id}"
          cd =
          { id: "#{self.uid}_#{uid}",
            origin_uid_s: self.uid,
            block_child_type: ["related_definitions"],
            "related_#{Definition.uid_prefix}_content_s" => d.content,
            "related_#{Definition.uid_prefix}_path_s" => path.join('/'),
            "related_#{Definition.uid_prefix}_level_i" => path.size,
            "related_#{Definition.uid_prefix}_language_s" => d.language.name,
            "related_#{Definition.uid_prefix}_language_code_s" => d.language.code,
            "related_#{Definition.uid_prefix}_etymologies_ss" => d.etymologies.collect(&:content),
            block_type: ['child']
          }
          d.etymologies.each do |de|
            cd["related_#{Definition.uid_prefix}_etymology_#{de.id}_content_ss"] = de.content
            etymology_type = de.etymology_type_association
            subject = etymology_type.nil? ? nil : etymology_type.subject
            cd["related_#{Definition.uid_prefix}_etymology_#{de.id}_type_#{subject['uid']}_ss"] = subject['header'] if !subject.nil?
          end
          author = d.author
          cd["related_#{Definition.uid_prefix}_author_s"] = d.author.fullname if !author.nil?
          cd["related_#{Definition.uid_prefix}_numerology_i"] = d.numerology if !d.numerology.nil?
          cd["related_#{Definition.uid_prefix}_tense_s"] = d.tense if !d.tense.nil?
          citation_references = d.standard_citations.collect { |c| c.info_source.bibliographic_reference }
          cd["related_#{Definition.uid_prefix}_citation_references_ss"] = citation_references if !citation_references.blank?
          info_source = d.legacy_citations.collect(&:info_source).first
          cd["related_#{Definition.uid_prefix}_source_s"] = info_source.title if !info_source.nil?
          subject_associations = d.definition_subject_associations
          related_branches = subject_associations.select(:branch_id).distinct.collect(&:branch_id)
          related_branches.each do |branch_id|
            branch = SubjectsIntegration::Feature.find(branch_id)
            cd["related_#{Definition.uid_prefix}_branch_#{branch.uid}_header_s"] = branch.header
            headers = []
            uids = []
            subject_associations.where(branch_id: branch_id).each do |association|
              subject = SubjectsIntegration::Feature.find(association.subject_id)
              uids << subject.uid
              headers << subject.header
            end
            cd["related_#{Definition.uid_prefix}_branch_#{branch.uid}_#{SubjectsIntegration::Feature.uid_prefix}_headers_t"] = headers
            cd["related_#{Definition.uid_prefix}_branch_#{branch.uid}_#{SubjectsIntegration::Feature.uid_prefix}_uids_t"] = uids
          end
          cd
        end
        child_documents = child_documents + self.recordings.collect do |recording|
          {id: "#{self.uid}_recording_#{recording.id}",
           block_child_type: ['terms_recording'],
           block_type: ['child'],
           recording_url: "#{TermsEngine::Configuration.server_url}#{helpers.rails_blob_path(recording.audio_file, disposition: 'attachment', only_path: true)}",
           recording_dialect_s: recording.dialect['header'],
           recording_dialect_uid_s: recording.dialect['uid']
          }
        end
        subject_associations = self.subject_term_associations
        doc = { tree: Feature.uid_prefix,
                associated_subjects: subject_associations.collect{ |a| a.subject['header'] },
                associated_subject_ids: subject_associations.collect(&:subject_id),
                etymologies_ss: self.etymologies.collect(&:content),
                block_type: ['parent'],
                '_childDocuments_'  => child_documents }
        subject_associations.collect do |sa|
          doc["related_#{Feature.uid_prefix}_branch_#{sa.branch_id}_#{SubjectsIntegration::Feature.uid_prefix}_#{sa.subject_id}_citation_references_ss"] = sa.citations.collect { |c| c.info_source.bibliographic_reference }
        end
        self.etymologies.each do |e|
          doc["etymology_#{e.id}_content_ss"] = e.content
          etymology_type = e.etymology_type_association
          subject = etymology_type.nil? ? nil : etymology_type.subject
          doc["etymology_#{e.id}_type_#{subject['uid']}_ss"] = subject['header'] if !subject.nil?
        end
        for branch_id in subject_associations.select(:branch_id).distinct.collect(&:branch_id)
          associations = subject_associations.where(branch_id: branch_id)
          doc["associated_subject_#{branch_id}_ls"] = associations.collect(&:subject_id)
          doc["associated_subject_#{branch_id}_ss"] = associations.collect{ |a| a.subject['header'] }
        end
        doc
      end
      
      module ClassMethods
        
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
          names = FeatureName.where(name: name).includes(feature: :subject_term_associations)
          name_position = names.find_index{ |n| n.feature.subject_term_associations.collect(&:subject_id).include? phoneme_id }
          name_position.nil? ? nil : names[name_position].feature
        end

        def search_by_eng_phoneme(name, phoneme_id)
          names = FeatureName.where('lower(name) = ?', name.downcase).includes(feature: :subject_term_associations)
          name_position = names.find_index{ |n| n.feature.subject_term_associations.collect(&:subject_id).include? phoneme_id }
          name_position.nil? ? nil : names[name_position].feature
        end

        def search_by_excluding_phoneme(name, branch_id, phoneme_id)
          names = FeatureName.where('lower(name) = ?', name.downcase).includes(feature: :subject_term_associations)
          name_position = names.find_index do |n|
            !(n.feature.subject_term_associations.find_index { |a| a.branch_id == branch_id && a.subject_id != phoneme_id }).nil?
          end
          name_position.nil? ? nil : names[name_position].feature
        end

        def search_english_term(name)
          Feature.search_by_excluding_phoneme(name, ENG_PHONEME_SUBJECT_ID, ENG_LETTER_SUBJECT_ID)
        end

        def search_bod_expression(name)
          Feature.search_by_phoneme(name, BOD_EXPRESSION_SUBJECT_ID)
        end

      end
    end
  end
end
