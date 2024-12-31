require 'csv'
module TermsEngine
  class FeatureNameMatch
    
    # input1, input2, matching_column
    def self.match(**args)
      table1 = CSV.parse(File.read(args[:input1]), headers: true, col_sep: "\t")
      table2 = CSV.parse(File.read(args[:input2]), headers: true, col_sep: "\t")
      perspective = Perspective.get_by_code(args[:perspective_code])
      case perspective.code
      when 'tib.alpha'
        matcher1 = table1[args[:matching_column]].collect{|w| w.blank? ? w : w.tibetan_cleanup + String::INTERSYLLABIC_TSHEG}
        matcher2 = table2[args[:matching_column]].collect{|w| w.blank? ? w : w.tibetan_cleanup + String::INTERSYLLABIC_TSHEG}
      else
        matcher1 = table1[args[:matching_column]].collect{|w| w.blank? ? w : w.strip}
        matcher2 = table2[args[:matching_column]].collect{|w| w.blank? ? w : w.strip}
      end
      corr_2_to_1 = Array.new(matcher2.size)
      current1 = 0
      size1 = matcher1.size
      matcher2.each_index do |i|
        field2 = matcher2[i]
        next if field2.nil?
        remaining1 = matcher1[current1..size1]
        pos1 = remaining1.index{ |field1| field2==field1 }
        pos1 = remaining1.index{ |field1| field2.start_with?(field1) } if pos1.nil?
        if !pos1.nil?
          current1 += pos1
          corr_2_to_1[i] = current1
          current1 += 1
        end
      end
      table1_col_num = table1.headers.size
      CSV.open(args[:output], 'wb', col_sep: "\t") do |csv|
        csv << table1.headers + table2.headers
        i1 = 0
        table2.each_with_index do |row2, i2|
          pos1 = corr_2_to_1[i2]
          if pos1.nil?
            csv << Array.new(table1_col_num) + row2.fields
          else
            while i1 < pos1
              csv << table1[i1].fields
              i1 += 1
            end
            csv << table1[i1].fields + row2.fields
            i1 += 1
          end
        end
        while i1 < size1
          csv << table1[i1].fields
          i1 += 1
        end
      end
    end
  end
end