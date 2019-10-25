require 'rails_helper'
require 'rake'
Rails.application.load_tasks

RSpec.describe TibetanTermsService do
  describe "Handling tibetan phrases" do
    before(:all) do
      # Needed to populate languages, writing systems, etc.
      Rake::Task['kmaps_engine:db:seed'].invoke
      
      # Needed to populate perspective
      Rake::Task['terms_engine:db:seed'].invoke
      # Preparing letters
      ComplexScripts::TibetanLetter.all.each { |letter| TibetanTermsService.add_term(Feature::BOD_LETTER_SUBJECT_ID, letter.unicode, "#{letter.wylie}a") }
      ts = TibetanTermsService.new
      ts.reposition
      second_level_seed_data = ['ཀ', 'ཀི་ཅུ་རམ', 'ཀྱེ་མ', 'དཀའ་བརྩོན', 'རྐྱེན་ངན', 'བརྐྱངས']
      relation_type = FeatureRelationType.get_by_code('is.beginning.of')
      tib_alpha = Perspective.get_by_code('tib.alpha')
      ka = Feature.current_roots_by_perspective(tib_alpha).first
      r = Random.new
      second_level_seed_data.sort_by{ |w| r.rand(10) }.each do |word|
        term = TibetanTermsService.add_term(Feature::BOD_PHRASE_SUBJECT_ID, word, nil)
        FeatureRelation.create!(child_node: term, parent_node: ka, perspective: tib_alpha, feature_relation_type: relation_type) if FeatureRelation.where(child_node: term, parent_node: ka).first.nil?
      end
      
    end
    
    context "Positioning phrases among root letters" do
      it "Identifies root letter position" do
        ts = TibetanTermsService.new
        # See complex_scripts/app/models/tibetan_letter.rb for position (corresponding to id-1 in that passive model)
        expect(ts.position_for('ཀི་ཅུ་རམ')).to eq(0)
        expect(ts.position_for('ཀྱེ་མ')).to eq(0)
        expect(ts.position_for('དཀའ་བརྩོན')).to eq(0)
        expect(ts.position_for('རྐྱེན་ངན')).to eq(0)
        expect(ts.position_for('བརྐྱངས')).to eq(0)
        expect(ts.position_for('མཇལ་དར')).to eq(6)
        expect(ts.position_for('གནས་སྐོར')).to eq(11)
        expect(ts.position_for('སྦྱང་ནག')).to eq(14)
        expect(ts.position_for('གཞའ')).to eq(20)
      end

      it "Identifies root letter" do
        ts = TibetanTermsService.new
        v = View.get_by_code('pri.tib.sec.roman')
        expect(ts.trunk_for('ཀི་ཅུ་རམ').prioritized_name(v).name).to eq('ཀ')
        expect(ts.trunk_for('ཀྱེ་མ').prioritized_name(v).name).to eq('ཀ')
        expect(ts.trunk_for('དཀའ་བརྩོན').prioritized_name(v).name).to eq('ཀ')
        expect(ts.trunk_for('རྐྱེན་ངན').prioritized_name(v).name).to eq('ཀ')
        expect(ts.trunk_for('བརྐྱངས').prioritized_name(v).name).to eq('ཀ')
        expect(ts.trunk_for('མཇལ་དར').prioritized_name(v).name).to eq('ཇ')
        expect(ts.trunk_for('གནས་སྐོར').prioritized_name(v).name).to eq('ན')
        expect(ts.trunk_for('སྦྱང་ནག').prioritized_name(v).name).to eq('བ')
        expect(ts.trunk_for('གཞའ').prioritized_name(v).name).to eq('ཞ')
      end
    end
    
    context "Second level phrases" do
      it "Sorts phrases" do
        tib_alpha = Perspective.get_by_code('tib.alpha')
        ka = Feature.current_roots_by_perspective(tib_alpha).first
        ts = TibetanTermsService.new(ka)
        expected = ['ཀ', 'ཀི་ཅུ་རམ', 'ཀྱེ་མ', 'དཀའ་བརྩོན', 'རྐྱེན་ངན', 'བརྐྱངས']
        v = View.get_by_code('pri.tib.sec.roman')
        sorted = ts.sorted_terms.collect{|f| f.prioritized_name(v).name }
        expect(sorted).to eq(expected)
      end
      
      it "Updates position for phrases" do
        tib_alpha = Perspective.get_by_code('tib.alpha')
        ka = Feature.current_roots_by_perspective(tib_alpha).first
        ts = TibetanTermsService.new(ka)
        ts.reposition
        expected = ['ཀ', 'ཀི་ཅུ་རམ', 'ཀྱེ་མ', 'དཀའ་བརྩོན', 'རྐྱེན་ངན', 'བརྐྱངས']
        v = View.get_by_code('pri.tib.sec.roman')
        sorted = ka.children.order('position').collect{|f| f.prioritized_name(v).name }
        expect(sorted).to eq(expected)
      end
      
    end
  end
end
