module TermsEngine
  module Extension
    module FeatureModel
      extend ActiveSupport::Concern

      included do
        PHONEME_SUBJECT_ID = 9310
        LETTER_SUBJECT_ID = 9311
        NAME_SUBJECT_ID = 9312
        PHRASE_SUBJECT_ID = 9314
        EXPRESSION_SUBJECT_ID = 9315
        
        has_many :subject_term_associations, dependent: :destroy
        has_many :phoneme_term_associations
        has_many :recordings, dependent: :destroy
        
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
        end
      end
      
      def pid
        "T#{self.fid}"
      end
      
      def phonemes
        self.phoneme_term_associations.collect(&:subject)
      end
      
      def document_for_rsolr
        per = Perspective.get_by_code(KmapsEngine::ApplicationSettings.default_perspective_code)
        v = View.get_by_code(KmapsEngine::ApplicationSettings.default_view_code)
        child_documents = self.parent_relations.collect do |pr|
          parent_node = pr.parent_node
          name = parent_node.prioritized_name(v)
          name_str = name.nil? ? nil : name.name
          parent = pr.parent_node
          cd =
          { id: "#{self.uid}_#{pr.feature_relation_type.code}_#{parent.fid}",
            related_uid_s: parent.uid,
            origin_uid_s: self.uid,
            block_child_type: ["related_#{Feature.uid_prefix}"],
            "related_#{Feature.uid_prefix}_id_s" => "#{Feature.uid_prefix}-#{parent.fid}",
            "related_#{Feature.uid_prefix}_header_s" => name_str,
            "related_#{Feature.uid_prefix}_path_s" => parent_node.closest_ancestors_by_perspective(per).collect(&:fid).join('/'),
            "related_#{Feature.uid_prefix}_relation_label_s" => pr.feature_relation_type.asymmetric_label,
            "related_#{Feature.uid_prefix}_relation_code_s" => pr.feature_relation_type.code,
            related_kmaps_node_type: 'parent',
            block_type: ['child']
          }
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
        child_documents = child_documents + self.child_relations.collect do |pr|
          child_node = pr.child_node
          name = child_node.prioritized_name(v)
          name_str = name.nil? ? nil : name.name
          child = pr.child_node
          cd =
          { id: "#{self.uid}_#{pr.feature_relation_type.asymmetric_code}_#{child.fid}",
            related_uid_s: child.uid,
            origin_uid_s: self.uid,
            block_child_type: ["related_#{Feature.uid_prefix}"],
            "related_#{Feature.uid_prefix}_id_s" => "#{Feature.uid_prefix}-#{child.fid}",
            "related_#{Feature.uid_prefix}_header_s" => name_str,
            "related_#{Feature.uid_prefix}_path_s" => child_node.closest_ancestors_by_perspective(per).collect(&:fid).join('/'),
            "related_#{Feature.uid_prefix}_relation_label_s" => pr.feature_relation_type.label,
            "related_#{Feature.uid_prefix}_relation_code_s" => pr.feature_relation_type.asymmetric_code,
            related_kmaps_node_type: 'child',
            block_type: ['child']
          }
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
            block_type: ['child']
          }
          author = d.author
          cd["related_#{Definition.uid_prefix}_author_s"] = d.author.fullname if !author.nil?
          cd["related_#{Definition.uid_prefix}_numerology_i"] = d.numerology if !d.numerology.nil?
          cd["related_#{Definition.uid_prefix}_tense_s"] = d.tense if !d.tense.nil?
          info_source = d.citations.where(info_source_type: InfoSource.model_name.name).collect(&:info_source).first
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
        subject_associations = self.subject_term_associations
        doc = { tree: Feature.uid_prefix,
                associated_subjects: subject_associations.collect{ |a| a.subject['header'] },
                associated_subject_ids: subject_associations.collect(&:subject_id),
                block_type: ['parent'],
                '_childDocuments_'  => child_documents }
        for branch_id in subject_associations.select(:branch_id).distinct.collect(&:branch_id)
          associations = subject_associations.where(branch_id: branch_id)
          doc["associated_subject_#{branch_id}_ls"] = associations.collect(&:subject_id)
          doc["associated_subject_#{branch_id}_ss"] = associations.collect{ |a| a.subject['header'] }
        end
        doc
      end
      
      module ClassMethods
        
        def search_by_phoneme(name, phoneme_id)
          names = FeatureName.where(name: name).includes(feature: :subject_term_associations)
          name_position = names.find_index{ |n| n.feature.subject_term_associations.collect(&:subject_id).include? phoneme_id }
          name_position.nil? ? nil : names[name_position].feature
        end
        
        def search_expression(name)
          Feature.search_by_phoneme(name, EXPRESSION_SUBJECT_ID)
        end
      end
    end
  end
end
