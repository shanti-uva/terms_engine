module TermsEngine
  class Filter
    attr_accessor :fields, :feature
    
    def do_feature_filter(filename:)
      rows = CSV.read(filename, headers: true, col_sep: "\t")
      puts 'features.fid'
      begin
        CSV.foreach(filename, headers: true, col_sep: "\t") do |row|
          self.fields = row.to_hash.delete_if{ |key, value| value.blank? }
          self.feature = nil
          self.infer_feature
          if self.feature.nil?
            puts ''
          else
            puts self.feature.fid
          end
        end
      rescue Exception => e
        puts "#{Time.now}: An error occured:"
        puts e.message
        puts e.backtrace.join("\n")
      end
    end
    
    def do_definition_filter(filename:, info_source:)
      rows = CSV.read(filename, headers: true, col_sep: "\t")
      puts ['features.fid', 'definition.id'].join("\t")
      begin
        CSV.foreach(filename, headers: true, col_sep: "\t") do |row|
          self.fields = row.to_hash.delete_if{ |key, value| value.blank? }
          self.get_feature
          if self.feature.nil?
            puts ''
          else
            definition = self.get_definition(info_source)
            puts [self.feature.fid, definition.nil? ? '' : definition.id].join("\t")
          end
        end
      rescue Exception => e
        puts "#{Time.now}: An error occured:"
        puts e.message
        puts e.backtrace.join("\n")
      end
    end
  
    
    def do_parent_filter(filename:)
      view = View.get_by_code('pri.orig.sec.roman')
      rows = CSV.read(filename, headers: true, col_sep: "\t")
      puts "features.fid\t1.feature_names.name"
      begin
        CSV.foreach(filename, headers: true, col_sep: "\t") do |row|
          self.fields = row.to_hash.delete_if{ |key, value| value.blank? }
          parent = self.infer_parent
          if parent.nil?
            puts ''
          else
            puts "#{parent.fid}\t#{parent.prioritized_name(view).name}"
          end
        end
      rescue Exception => e
        puts "#{Time.now}: An error occured:"
        puts e.message
        puts e.backtrace.join("\n")
      end
    end
    
    def infer_parent
      name_str = self.fields.delete("1.feature_names.name")
      return nil if name_str.nil?
      return TibetanTermsService.recursive_trunk_for(name_str.tibetan_cleanup)
    end
    
    def get_feature
      fid = self.fields.delete('features.fid')
      if fid.blank?
        puts "A \"features.fid\" must be present!"
        return false
      else
        feature = Feature.get_by_fid(fid)
        if feature.nil?
          self.say "Feature with THL ID #{fid} was not found."
          return false
        end
      end
      self.feature = feature
      return true
    end
    
    def infer_feature
      tibetan_str = nil
      wylie_str = nil
      newar_str = nil
      latin_str = nil
      1.upto(2) do |i|
        name_tag = "#{i}.feature_names"
        name_str = self.fields.delete("#{name_tag}.name")
        writing_system_str = self.fields.delete("#{i}.writing_systems.code")
        relationship_system_str = self.fields.delete("#{i}.feature_name_relations.relationship.code")
        case writing_system_str
        when 'tibt'
          tibetan_str = name_str.tibetan_cleanup if tibetan_str.blank?
        when 'deva'
          newar_str = name_str.strip
        else
          case relationship_system_str
          when 'thl.ext.wyl.translit'
            wylie_str = name_str.strip if wylie_str.blank?
          when 'indo.standard.translit'
            latin_str = name_str.strip if wylie_str.blank?
          end
        end
      end
      self.feature = Feature.search_bod_expression(tibetan_str) if !tibetan_str.blank?
      self.feature = Feature.search_bod_expression(wylie_str) if self.feature.nil? &&  !wylie_str.blank?
      self.feature = Feature.search_new_expression(newar_str) if self.feature.nil? &&  !newar_str.blank?
      self.feature = Feature.search_new_expression(latin_str) if self.feature.nil? &&  !latin_str.blank?
    end
    
    def get_definition(dict_info_source = nil)
      definitions = self.feature.definitions
      prefix = 'definition'
      definition_content = self.fields.delete("#{prefix}.content")
      return nil if definition_content.blank?
      def_begining = definition_content[0...200]
      def_begining = def_begining.split("\n").first
      def_with_tags = '<p>' + def_begining
      matches = definitions.where(["LEFT(content, #{def_begining.size}) = ? OR LEFT(content, #{def_with_tags.size}) = ?", def_begining, def_with_tags]) # find_by(content: definition_content)
      if dict_info_source.nil?
        return matches.first
      else
        matches.each do |d|
          citation = d.non_standard_citations.first
          #citations = d.citations.where(info_source_type: InfoSource.model_name.name)
          if !citation.nil?
            info_source = citation.info_source
            source_id = info_source.id
            if !info_source.processed? && info_source == dict_info_source
              return d
            end
          end
        end
      end
      return nil
    end
  end
end