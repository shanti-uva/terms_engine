module TermsEngine
  class Filter
    attr_accessor :fields, :feature
    
    def do_feature_filter(filename:)
      rows = CSV.read(filename, headers: true, col_sep: "\t")
      puts 'features.fid'
      begin
        CSV.foreach(filename, headers: true, col_sep: "\t") do |row|
          self.fields = row.to_hash.delete_if{ |key, value| value.blank? }
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
    
    def do_parent_filter(filename:)
      view = View.get_by_code('pri.tib.sec.roman')
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
    
    def infer_feature
      tibetan_str = nil
      wylie_str = nil
      1.upto(2) do |i|
        name_tag = "#{i}.feature_names"
        name_str = self.fields.delete("#{name_tag}.name")
        writing_system_str = self.fields.delete("#{i}.writing_systems.code")
        relationship_system_str = self.fields.delete("#{i}.feature_name_relations.relationship.code")
        if writing_system_str=='tibt'
          tibetan_str = name_str.tibetan_cleanup if tibetan_str.blank?
        elsif relationship_system_str=='thl.ext.wyl.translit'
          wylie_str = name_str.strip if wylie_str.blank?
        end
      end
      self.feature = Feature.search_bod_expression(tibetan_str) if !tibetan_str.blank?
      self.feature = Feature.search_bod_expression(wylie_str) if self.feature.nil? &&  !wylie_str.blank?
    end
  end
end