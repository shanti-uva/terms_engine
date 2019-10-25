require 'rails_helper'
require 'rake'
Rails.application.load_tasks

RSpec.describe EnglishTermsService do
  describe "Handling English phrases" do
    before(:all) do
      # Needed to populate languages, writing systems, etc.
      Rake::Task['kmaps_engine:db:seed'].invoke
      
      # Needed to populate perspective
      Rake::Task['terms_engine:db:seed'].invoke
      # Preparing letters
      ('A'..'Z').each { |letter| EnglishTermsService.add_term(Feature::ENG_LETTER_SUBJECT_ID, letter) }
      es = EnglishTermsService.new
      es.reposition
      second_level_seed_data = ['Analytic mind', 'Abstract thought', 'Animal insticts', 'Anomaly', 'Absent minded', 'Acquired taste']
      eng_alpha = Perspective.get_by_code('eng.alpha')
      relation_type = FeatureRelationType.get_by_code('is.beginning.of')
      a = Feature.current_roots_by_perspective(eng_alpha).first
      r = Random.new
      second_level_seed_data.sort_by{ |w| r.rand(10) }.each do |word|
        subject_id = word.split(' ').size > 1 ? Feature::ENG_PHRASE_SUBJECT_ID : Feature::ENG_WORD_SUBJECT_ID
        term = EnglishTermsService.add_term(subject_id, word)
        FeatureRelation.create!(child_node: term, parent_node: a, perspective: eng_alpha, feature_relation_type: relation_type) if FeatureRelation.where(child_node: term, parent_node: a).first.nil?
      end
    end
    
    context "Positioning phrases among root letters" do
      it "Identifies root letter position" do
        es = EnglishTermsService.new
        expect(es.position_for('Generosity')).to eq(6)
        expect(es.position_for('Virtue')).to eq(21)
        expect(es.position_for('Renunciation')).to eq(17)
        expect(es.position_for('Wisdom')).to eq(22)
        expect(es.position_for('Effort')).to eq(4)
        expect(es.position_for('Patience')).to eq(15)
        expect(es.position_for('Honesty')).to eq(7)
        expect(es.position_for('Determination')).to eq(3)
        expect(es.position_for('Loving-kindness')).to eq(11)
        expect(es.position_for('Equanimity')).to eq(4)
      end

      it "Identifies root letter" do
        es = EnglishTermsService.new
        v = View.get_by_code('roman.popular')
        expect(es.trunk_for('Generosity').prioritized_name(v).name).to eq('G')
        expect(es.trunk_for('Ethics').prioritized_name(v).name).to eq('E')
        expect(es.trunk_for('Patience').prioritized_name(v).name).to eq('P')
        expect(es.trunk_for('Effort').prioritized_name(v).name).to eq('E')
        expect(es.trunk_for('Concentration').prioritized_name(v).name).to eq('C')
        expect(es.trunk_for('Wisdom').prioritized_name(v).name).to eq('W')
      end
    end
    
    context "Second level phrases" do
      it "Sorts phrases" do
        eng_alpha = Perspective.get_by_code('eng.alpha')
        a = Feature.current_roots_by_perspective(eng_alpha).first
        es = EnglishTermsService.new(a)
        expected = ['Absent minded', 'Abstract thought', 'Acquired taste', 'Analytic mind', 'Animal insticts', 'Anomaly']
        v = View.get_by_code('roman.popular')
        sorted = es.sorted_terms.collect{|f| f.prioritized_name(v).name }
        expect(sorted).to eq(expected)
      end
      
      it "Updates position for phrases" do
        eng_alpha = Perspective.get_by_code('eng.alpha')
        a = Feature.current_roots_by_perspective(eng_alpha).first
        es = EnglishTermsService.new(a)
        es.reposition
        expected = ['Absent minded', 'Abstract thought', 'Acquired taste', 'Analytic mind', 'Animal insticts', 'Anomaly']
        v = View.get_by_code('roman.popular')
        sorted = a.children.order('position').collect{|f| f.prioritized_name(v).name }
        expect(sorted).to eq(expected)
      end
      
    end
  end
end
