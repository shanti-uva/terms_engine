module TermsEngine
  module FeatureOverrides
    # When this module is prepended into Feature…
    def self.prepended(base)
      # …also override class methods by prepending into the eigenclass.
      base.singleton_class.prepend ClassMethods
      # If you only want to ADD class methods (not override), use:
      # base.extend ClassMethods
    end
    
    def nested_documents_for_rsolr
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
        info_sources = pr.legacy_citations.collect(&:info_source)
        cd["#{prefix}_relation_source_code_ss"] = info_sources.collect(&:code) if !info_sources.blank?
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
        info_sources = pr.legacy_citations.collect(&:info_source)
        cd["#{prefix}_relation_source_code_ss"] = info_sources.collect(&:code) if !info_sources.blank?
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
        cd["#{def_prefix}_enumeration_i"] = d.enumeration.value if !d.enumeration.nil?
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
          s.translations.each do |t|
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
              enumeration_i: self.enumeration&.value,
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
        citations = sa.standard_citations
        citation_references = citations.collect { |c| c.bibliographic_reference }
        doc["#{subject_prefix}_citation_references_ss"] = citation_references if !citation_references.blank?
        citations.each{ |ci| ci.rsolr_document_tags_for_notes(doc, subject_prefix) }
        info_sources = sa.legacy_citations.collect(&:info_source)
        doc["#{subject_prefix}_source_code_ss"] = info_sources.collect(&:code) if !info_sources.blank?
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
        citations = e.standard_citations
        citation_references = citations.collect { |c| c.bibliographic_reference }
        doc["#{etymology_prefix}_citation_references_ss"] = citation_references if !citation_references.blank?
        citations.each{ |ci| ci.rsolr_document_tags_for_notes(doc, etymology_prefix) }
        info_source = e.legacy_citations.collect(&:info_source).first
        doc["#{etymology_prefix}_source_code_s"] = info_source.code if !info_source.nil?
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
    end
  end
end