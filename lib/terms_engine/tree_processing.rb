module TermsEngine
  class TreeProcessing
    def initialize
      @tib_alpha = Perspective.get_by_code('tib.alpha')
      @relation_type = FeatureRelationType.get_by_code('heads')
      @view = View.get_by_code('pri.tib.sec.roman')
    end
    
    def fix_expression(f)
      f.parent_relations.delete_all
      parent = TibetanTermsService.recursive_trunk_for(f)
      FeatureRelation.create!(child_node: f, parent_node: parent, perspective: @tib_alpha, feature_relation_type: @relation_type)
      ts = TibetanTermsService.new(parent)
      ts.reposition
    end
    
    def check
      letters = Feature.current_roots_by_perspective(@tib_alpha)
      letter_count = letters.size
      k = 0
      letters.each_index do |i|
        letter = letters[i]
        current_letter = letter.prioritized_name(@view).name
        puts "#{current_letter}: #{k}"
        next_letter = i+1<letter_count ? letters[i+1].prioritized_name(@view).name : nil
        phrases = letter.children.order(:position)
        phrase_count = phrases.size
        phrases.each_with_index do |phrase, j|
          current_phrase = phrase.prioritized_name(@view).name
          next_phrase = j+1<phrase_count ? phrases[j+1].prioritized_name(@view).name : next_letter
          expressions = phrase.children.order(:position)
          #previous = nil
          expressions.each do |expression|
            current = expression.prioritized_name(@view).name
            ok = current_phrase.bo_compare(current) <= 0
            ok &&= current.bo_compare(next_phrase) <= 0 if next_phrase.nil?
            if !ok
              puts "Fixing #{current}..."
              self.fix_expression(expression)
              k+=1
            end              
            #if !previous.nil?
            #  if previous.bo_compare(current)>0
            #    puts previous
            #    puts "#{current} !!!"
            #  end
            #end
            #previous = current
          end
        end
      end
      puts "#{k} terms fixed."
    end
  end
end