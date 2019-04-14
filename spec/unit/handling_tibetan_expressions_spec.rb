require 'rails_helper'
require 'rake'
Rails.application.load_tasks

RSpec.describe TermsService do
  describe "Handling tibetan expressions" do
    before(:all) do
      # Needed to populate languages, writing systems, etc.
      Rake::Task['kmaps_engine:db:seed'].invoke
      
      # Needed to populate perspective
      Rake::Task['terms_engine:db:seed'].invoke
      # Preparing letters
      ComplexScripts::TibetanLetter.all.each { |letter| TermsService.add_term(Feature::LETTER_SUBJECT_ID, letter.unicode, "#{letter.wylie}a") }
      ts = TermsService.new
      ts.reposition
      second_level_seed_data = ['ཀ', 'ཀི་ཅུ་རམ', 'ཀྱེ་མ', 'དཀའ་བརྩོན', 'རྐྱེན་ངན', 'བརྐྱངས']
      tib_alpha = Perspective.get_by_code('tib.alpha')
      relation_type = FeatureRelationType.get_by_code('is.beginning.of')
      ka = Feature.roots.order('position').first
      r = Random.new
      second_level_seed_data.each do |word|
        term = TermsService.add_term(Feature::PHRASE_SUBJECT_ID, word, nil)
        FeatureRelation.create!(child_node: term, parent_node: ka, perspective: tib_alpha, feature_relation_type: relation_type) if FeatureRelation.where(child_node: term, parent_node: ka).first.nil?
      end
      ts = TermsService.new(ka)
      ts.reposition
    end
    
    context "Positioning expressions among phrases" do
      it "Identifies parent phrase" do
        v = View.get_by_code('pri.tib.sec.roman')
        expect(TermsService.recursive_trunk_for('ཀ་དག').prioritized_name(v).name).to eq('ཀ')
        expect(TermsService.recursive_trunk_for('ཀོ་གདན').prioritized_name(v).name).to eq('ཀི་ཅུ་རམ')
        expect(TermsService.recursive_trunk_for('ཀླད་').prioritized_name(v).name).to eq('ཀྱེ་མ')
        expect(TermsService.recursive_trunk_for('བཀྲ་ཤིས་').prioritized_name(v).name).to eq('དཀའ་བརྩོན')
        expect(TermsService.recursive_trunk_for('སྐད').prioritized_name(v).name).to eq('རྐྱེན་ངན')
        expect(TermsService.recursive_trunk_for('བསྐྲོག').prioritized_name(v).name).to eq('བརྐྱངས')
      end
    end
    
    context "Adding expressions" do
      it "Identifies right parent" do
        expression_to_be_added = 'བཀྲ་ཤིས་'
        parent = TermsService.recursive_trunk_for(expression_to_be_added)
        term = TermsService.add_term(Feature::EXPRESSION_SUBJECT_ID, expression_to_be_added, nil)
        tib_alpha = Perspective.get_by_code('tib.alpha')
        relation_type = FeatureRelationType.get_by_code('is.beginning.of')
        FeatureRelation.create!(child_node: term, parent_node: parent, perspective: tib_alpha, feature_relation_type: relation_type)
        
        ts = TermsService.new(parent)
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