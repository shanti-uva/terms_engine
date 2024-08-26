require 'rails_helper'
require 'rake'
Rails.application.load_tasks

RSpec.describe TibetanTermsService do
  describe "Handling tibetan expressions" do
    before(:all) do
      # Needed to populate languages, writing systems, etc.
      Rake::Task['kmaps_engine:db:seed'].invoke
      
      # Needed to populate perspective
      Rake::Task['terms_engine:db:seed'].invoke
      # Preparing letters
      ComplexScripts::TibetanLetter.all.each { |letter| TibetanTermsService.add_term(level_subject_id: Feature::BOD_LETTER_SUBJECT_ID, tibetan: letter.unicode, wylie: "#{letter.wylie}a") }
      ts = TibetanTermsService.new
      ts.reposition
      second_level_seed_data = ['ཀ', 'ཀི་ཅུ་རམ', 'ཀྱེ་མ', 'དཀའ་བརྩོན', 'རྐྱེན་ངན', 'བརྐྱངས']
      relation_type = FeatureRelationType.get_by_code('is.beginning.of')
      tib_alpha = Perspective.get_by_code('tib.alpha')
      ka = Feature.current_roots_by_perspective(tib_alpha).first
      r = Random.new
      second_level_seed_data.each do |word|
        term = TibetanTermsService.add_term(level_subject_id: Feature::BOD_PHRASE_SUBJECT_ID, tibetan: word)
        FeatureRelation.create!(child_node: term, parent_node: ka, perspective: tib_alpha, feature_relation_type: relation_type) if FeatureRelation.where(child_node: term, parent_node: ka).first.nil?
      end
      ts = TibetanTermsService.new(ka)
      ts.reposition
    end
    
    context "Positioning expressions among phrases" do
      it "Identifies parent phrase" do
        v = View.get_by_code('pri.tib.sec.roman')
        expect(TibetanTermsService.recursive_trunk_for('ཀ་དག').prioritized_name(v).name).to eq('ཀ')
        expect(TibetanTermsService.recursive_trunk_for('ཀོ་གདན').prioritized_name(v).name).to eq('ཀི་ཅུ་རམ')
        expect(TibetanTermsService.recursive_trunk_for('ཀླད་').prioritized_name(v).name).to eq('ཀྱེ་མ')
        expect(TibetanTermsService.recursive_trunk_for('བཀྲ་ཤིས་').prioritized_name(v).name).to eq('དཀའ་བརྩོན')
        expect(TibetanTermsService.recursive_trunk_for('སྐད').prioritized_name(v).name).to eq('རྐྱེན་ངན')
        expect(TibetanTermsService.recursive_trunk_for('བསྐྲོག').prioritized_name(v).name).to eq('བརྐྱངས')
      end
    end
    
    context "Adding expressions" do
      it "Identifies right parent" do
        expression_to_be_added = 'བཀྲ་ཤིས་'
        parent = TibetanTermsService.recursive_trunk_for(expression_to_be_added)
        term = TibetanTermsService.add_term(level_subject_id: Feature::BOD_EXPRESSION_SUBJECT_ID, wylie: expression_to_be_added)
        tib_alpha = Perspective.get_by_code('tib.alpha')
        relation_type = FeatureRelationType.get_by_code('is.beginning.of')
        FeatureRelation.create!(child_node: term, parent_node: parent, perspective: tib_alpha, feature_relation_type: relation_type)
        
        ts = TibetanTermsService.new(parent)
        ts.reposition
        term.reload
        expect(term.position).to eq(1)
        v = View.get_by_code('pri.tib.sec.roman')
        ancestors = term.ancestors_by_perspective(tib_alpha)
        expect(ancestors.collect{|f| f.prioritized_name(v).name}).to eq(["ཀ", "དཀའ་བརྩོན", "བཀྲ་ཤིས་"])
      end
    end
  end
end
