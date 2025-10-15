module TermsEngine
  module FeatureExtensions
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
      has_many :etymologies, as: :context, dependent: :destroy do
        def all
          if @all_etymologies.nil?
            etymologies = self
            standard = []
            legacy = {}
            in_house = {}
            etymologies.each do |e|
              citation = e.legacy_citations.first
              #citations = d.citations.where(info_source_type: InfoSource.model_name.name)
              if citation.nil?
                standard << e
              else
                info_source = citation.info_source
                source_id = info_source.id
                if info_source.processed?
                  in_house[source_id] ||= []
                  in_house[source_id] << e
                else
                  legacy[source_id] ||= []
                  legacy[source_id] << e
                end
              end
            end
            @all_etymologies = { standard: standard, in_house: in_house, legacy: legacy }
          end
          @all_etymologies
        end
        
        def standard
          all[:standard]
        end
        
        def in_house_by_info_source
          all[:in_house]
        end
        
        def legacy_by_info_source
          all[:legacy]
        end
      end
      has_many :model_sentences, as: :context, dependent: :destroy
      has_many :phoneme_term_associations, dependent: :destroy
      has_many :non_phoneme_term_associations, dependent: :destroy do
        def all
          if @all_subject_term_associations.nil?
            subject_term_associations = self
            standard = []
            legacy = {}
            in_house = {}
            subject_term_associations.each do |a|
              citations = a.legacy_citations
              #citations = d.citations.where(info_source_type: InfoSource.model_name.name)
              if citations.blank?
                standard << a
              else
                citations.each do |citation|
                  info_source = citation.info_source
                  source_id = info_source.id
                  if info_source.processed?
                    in_house[source_id] ||= []
                    in_house[source_id] << a
                  else
                    legacy[source_id] ||= []
                    legacy[source_id] << a
                  end
                end
              end
            end
            @all_subject_term_associations = { standard: standard, in_house: in_house, legacy: legacy }
          end
          @all_subject_term_associations
        end
        
        def standard
          all[:standard]
        end
        
        def in_house_by_info_source
          all[:in_house]
        end
        
        def legacy_by_info_source
          all[:legacy]
        end
      end
      has_many :recordings, dependent: :destroy do
        def corrupted
          self.select{ |r| r.corrupted? }
        end
      end
      has_many :subject_term_associations, dependent: :destroy
      has_many :translation_equivalents, dependent: :destroy do
        def all
          if @translation_equivalents.nil?
            translation_equivalents = self
            standard = []
            legacy = {}
            in_house = {}
            translation_equivalents.each do |t|
              citations = t.legacy_citations
              #citations = d.citations.where(info_source_type: InfoSource.model_name.name)
              if citations.blank?
                standard << t
              else
                citations.each do |citation|
                  info_source = citation.info_source
                  source_id = info_source.id
                  if info_source.processed?
                    in_house[source_id] ||= {}
                    in_house[source_id][t.language_id] ||= []
                    in_house[source_id][t.language_id] << t
                  else
                    legacy[source_id] ||= {}
                    legacy[source_id][t.language_id] ||= []
                    legacy[source_id][t.language_id] << t
                  end
                end
              end
            end
            @translation_equivalents = { standard: standard, in_house: in_house, legacy: legacy }
          end
          @translation_equivalents
        end
        
        def standard
          all[:standard]
        end
        
        def in_house_by_info_source
          all[:in_house]
        end
        
        def legacy_by_info_source
          all[:legacy]
        end
      end
      
      has_one  :enumeration, as: :context, dependent: :destroy
      
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

        def all
          if @all_definitions.nil?
            definitions = self.roots
            standard = []
            legacy = {}
            in_house = {}
            definitions.each do |d|
              citation = d.non_standard_citations.first
              #citations = d.citations.where(info_source_type: InfoSource.model_name.name)
              if citation.nil?
                standard << d
              else
                info_source = citation.info_source
                source_id = info_source.id
                if info_source.processed?
                  in_house[source_id] ||= []
                  in_house[source_id] << d
                else
                  legacy[source_id] ||= []
                  legacy[source_id] << d
                end
              end
            end
            @all_definitions = { standard: standard, in_house: in_house, legacy: legacy }
          end
          @all_definitions
        end
        
        def standard
          all[:standard]
        end
        
        def in_house_by_info_source
          all[:in_house]
        end

        def legacy_by_info_source
          all[:legacy]
        end
      end
    end
    
    def legacy_info_sources
      definitions_hash = self.definitions.legacy_by_info_source
      translation_equivalents_hash = self.translation_equivalents.legacy_by_info_source
      subject_associations_hash = self.non_phoneme_term_associations.legacy_by_info_source
      etymologies_hash = self.etymologies.legacy_by_info_source
      relations_hash = self.legacy_relations_by_info_source
      definitions_hash.keys.union(translation_equivalents_hash.keys).union(relations_hash.keys).union(subject_associations_hash.keys).union(etymologies_hash.keys)
    end
    
    def in_house_info_sources
      definitions_hash = self.definitions.in_house_by_info_source
      translation_equivalents_hash = self.translation_equivalents.in_house_by_info_source
      subject_associations_hash = self.non_phoneme_term_associations.in_house_by_info_source
      etymologies_hash = self.etymologies.in_house_by_info_source
      relations_hash = self.in_house_relations_by_info_source
      definitions_hash.keys.union(translation_equivalents_hash.keys).union(relations_hash.keys).union(subject_associations_hash.keys).union(etymologies_hash.keys)
    end
    
    def all_relations_by_info_source
      if @all_relations.nil?
        all_relations = self.all_relations
        standard = []
        legacy = {}
        in_house = {}
        all_relations.each do |r|
          citation = r.legacy_citations
          #citations = d.citations.where(info_source_type: InfoSource.model_name.name)
          if citations.blank?
            standard << r
          else
            citations.each do |citation|
              info_source = citation.info_source
              source_id = info_source.id
              if info_source.processed?
                in_house[source_id] ||= []
                in_house[source_id] << r
              else
                legacy[source_id] ||= []
                legacy[source_id] << r
              end
            end
          end
        end
        @all_relations = { standard: standard, in_house: in_house, legacy: legacy }
      end
      @all_relations
    end
    
    def standard_relations
      all_relations_by_info_source[:standard]
    end
    
    def in_house_relations_by_info_source
      all_relations_by_info_source[:in_house]
    end
    
    def legacy_relations_by_info_source
      all_relations_by_info_source[:legacy]
    end
    
    def legacy_relations(info_source)
      self.all_relations.reject{ |r| r.legacy_citations.where(info_source: info_source).first.nil? }
    end
    
    def legacy_parent_relations(info_source)
      self.all_parent_relations.reject{ |r| r.legacy_citations.where(info_source: info_source).first.nil? }
    end
    
    def legacy_child_relations(info_source)
      self.all_child_relations.reject{ |r| r.legacy_citations.where(info_source: info_source).first.nil? }
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
    
    def calculate_prioritized_name(current_view)
      all_names = prioritized_names
      case current_view.code
      when 'roman.scholar'
        name = scholarly_prioritized_name(all_names)
      when 'pri.orig.sec.roman'
        name = tibetan_prioritized_name(all_names)
        name = KmapsEngine::FeatureExtensionForNamePositioning::HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('deva').id) if name.nil?
      end
      name || popular_prioritized_name(all_names)
    end
    
    def bod_expression?
      !self.phoneme_term_associations.where(branch_id: Feature::BOD_PHONEME_SUBJECT_ID, subject_id: Feature::BOD_EXPRESSION_SUBJECT_ID).first.nil?
    end
    
    class_methods do
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
      
      def search_by_phoneme(name, phoneme_id)
        name = FeatureName.joins(feature: :subject_term_associations).where(name: name, 'subject_term_associations.subject_id' => Feature::BOD_EXPRESSION_SUBJECT_ID).first
        name&.feature
        #name_position = names.find_index{ |n| n.feature.phoneme_term_associations.collect(&:subject_id).include? phoneme_id }
        #name_position.nil? ? nil : names[name_position].feature
      end

      def search_by_eng_phoneme(name, phoneme_id)
        names = FeatureName.where('lower(name) = ?', name.downcase).joins(feature: :subject_term_associations)
        name_position = names.find_index{ |n| n.feature.phoneme_term_associations.collect(&:subject_id).include? phoneme_id }
        name_position.nil? ? nil : names[name_position].feature
      end

      def search_by_excluding_phoneme(name, branch_id, phoneme_id)
        names = FeatureName.where('lower(name) = ?', name.downcase).joins(feature: :subject_term_associations)
        name_position = names.find_index do |n|
          !(n.feature.phoneme_term_associations.find_index { |a| a.branch_id == branch_id && a.subject_id != phoneme_id }).nil?
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
        name&.feature
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
        name&.feature
      end
      
      def solr_url
        URI.join(TermsResource.get_url, "solr/")
      end
    end
  end
end