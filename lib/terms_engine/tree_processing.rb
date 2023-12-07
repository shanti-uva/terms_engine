module TermsEngine
  class TreeProcessing
    def initialize
      @tib_alpha = Perspective.get_by_code('tib.alpha')
      @new_alpha = Perspective.get_by_code('new.alpha')
      @relation_type = FeatureRelationType.get_by_code('heads')
      @view = View.get_by_code('pri.orig.sec.roman')
      @fixed_size = 100
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
            ok &&= current.bo_compare(next_phrase) < 0 if !next_phrase.nil?
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
    
    def run_tibetan_tree_flattening_fixed
      v = View.get_by_code('roman.scholar')
      relation_type = @relation_type
      Feature.current_roots_by_perspective(@tib_alpha).sort_by{|f| f.position}.each do |letter|
        puts "#{Time.now}: Deleting names under letter #{letter.prioritized_name(v).name}..."
        destroy_features(get_tib_term_fids_under_letter_by_phoneme(letter.fid, Feature::BOD_NAME_SUBJECT_ID))
        puts "#{Time.now}: Deleting phrases under letter #{letter.prioritized_name(v).name}..."
        destroy_features(get_tib_term_fids_under_letter_by_phoneme(letter.fid, Feature::BOD_PHRASE_SUBJECT_ID))
        # there should not be children if index was correct
        destroy_features(letter.children.order(:fid).collect(&:fid))
        expressions = get_tib_term_fids_under_letter_by_phoneme(letter.fid, Feature::BOD_EXPRESSION_SUBJECT_ID)
        head = nil
        sid = Spawnling.new do
          begin
            puts "#{Time.now}: Spawning sub-process #{Process.pid} for processing of expressions under letter #{letter.prioritized_name(v).name}..."
            expressions.each_index do |i|
              f = Feature.get_by_fid(expressions[i])
              if i % @fixed_size == 0
                head = f.clone_with_names
                FeatureRelation.create!(child_node: head, parent_node: letter, perspective: @tib_alpha, feature_relation_type: relation_type)
                head.subject_term_associations.create(subject_id: Feature::BOD_PHRASE_SUBJECT_ID, branch_id: Feature::BOD_PHONEME_SUBJECT_ID)
                head.update(is_public: true, position: f.position)
                puts "#{Time.now}: Created head #{head.prioritized_name(v).name} (#{head.fid}) under letter #{letter.prioritized_name(v).name}..."
              end
              FeatureRelation.create!(child_node: f, parent_node: head, perspective: @tib_alpha, feature_relation_type: relation_type)
            end
            puts "#{Time.now}: Finishing sub-process #{Process.pid}."
          rescue Exception => e
            STDERR.puts e.to_s
          end
        end
        Spawnling.wait([sid])
      end
      Flare.commit
    end

    def run_newar_tree_flattening_fixed
      v = View.get_by_code('roman.scholar')
      heads_type = @relation_type
      starts_type = FeatureRelationType.get_by_code('is.beginning.of')
      Feature.current_roots_by_perspective(@new_alpha).sort_by{|f| f.position}.each do |letter|
        sid = Spawnling.new do
          begin
            letter.skip_update = true
            puts "#{Time.now}: Deleting intermediate level under letter #{letter.prioritized_name(v).name}..."
            expression_fids = get_new_term_fids_under_letter_by_phoneme(letter.fid, Feature::NEW_EXPRESSION_SUBJECT_ID)
            expressions = expression_fids.collect{ |id| Feature.get_by_fid(id) }
            expressions.each{ |f| f.skip_update = true }
            destroy_features(get_new_term_fids_under_letter_by_phoneme(letter.fid, Feature::NEW_PLACE_HOLDER_SUBJECT_ID))
            head = nil
            puts "#{Time.now}: Spawning sub-process #{Process.pid} for processing of expressions under letter #{letter.prioritized_name(v).name}..."
            expressions.each_index do |i|
              f = expressions[i]
              if i % @fixed_size == 0
                if !head.nil?
                  head.skip_update = false
                  head.queued_index(priority: 2)
                end
                head = f.clone_with_names
                head.update(is_public: true, position: f.position, skip_update: true)
                FeatureRelation.create!(child_node: head, parent_node: letter, perspective: @new_alpha, feature_relation_type: starts_type)
                head.subject_term_associations.create(subject_id: Feature::NEW_PLACE_HOLDER_SUBJECT_ID, branch_id: Feature::BOD_PHONEME_SUBJECT_ID)
                puts "#{Time.now}: Created head #{head.prioritized_name(v).name} (#{head.fid}) under letter #{letter.prioritized_name(v).name}..."
              end
              letter_relation = FeatureRelation.where(parent_node: letter, child_node: f).first
              letter_relation.skip_update = true
              letter_relation.destroy if !letter_relation.nil?
              FeatureRelation.create!(child_node: f, parent_node: head, perspective: @new_alpha, feature_relation_type: heads_type)
            end
            letter.skip_update = false
            letter.queued_index(priority: 1)
            puts "#{Time.now}: Finishing sub-process #{Process.pid}."
          rescue Exception => e
            STDERR.puts e.to_s
          end
        end
        Spawnling.wait([sid])
      end
      puts "#{Time.now}: Finished tree generation."
    end
    
    private
    
    def get_tib_term_fids_under_letter_by_phoneme(letter_fid, phoneme_sid)
      query = "tree:terms AND ancestor_ids_tib.alpha:#{letter_fid} AND associated_subject_#{Feature::BOD_PHONEME_SUBJECT_ID}_ls:#{phoneme_sid}"
      numFound = Feature.search_by(query)['numFound']
      resp = Feature.search_by(query, fl: 'uid', rows: numFound, sort: 'position_i asc')['docs']
      resp.collect{|f| f['uid'].split('-').last.to_i}
    end
    
    def get_new_term_fids_under_letter_by_phoneme(letter_fid, phoneme_sid)
      query = "tree:terms AND ancestor_ids_new.alpha:#{letter_fid} AND associated_subject_#{Feature::NEW_PHONEME_SUBJECT_ID}_ls:#{phoneme_sid}"
      numFound = Feature.search_by(query)['numFound']
      resp = Feature.search_by(query, fl: 'uid', rows: numFound, sort: 'position_i asc')['docs']
      resp.collect{|f| f['uid'].split('-').last.to_i}
    end
    
    def destroy_features(fids)
      fids.each do |fid|
        f = Feature.get_by_fid(fid)
        if !f.nil?
          f.remove!
          f.destroy
          puts "#{Time.now}: Deleted term #{fid}."
        end
      end
    end
  end
end