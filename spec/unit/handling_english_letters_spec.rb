require 'rails_helper'
require 'rake'
Rails.application.load_tasks

RSpec.describe EnglishTermsService do
  describe "Handling English letters" do
    before(:all) do
      # Needed to populate languages, writing systems, etc.
      Rake::Task['kmaps_engine:db:seed'].invoke
      # Needed to populate perspective
      Rake::Task['terms_engine:db:seed'].invoke
      
      # Adding letters randomly in order to test sorting in DB
      r = Random.new
      ('A'..'Z').each.sort_by { |l| r.rand(100) }.each { |letter| EnglishTermsService.add_term(Feature::ENG_LETTER_SUBJECT_ID, letter) }
    end

    context "Sorting" do
      it "Sorts letters" do
        es = EnglishTermsService.new
        expected = ('A'..'Z').to_a
        v = View.get_by_code('roman.popular')
        sorted = es.sorted_terms.collect{|f| f.prioritized_name(v).name }
        expect(sorted).to eq(expected)
      end
      
      it "Updates position for letters" do
        es = EnglishTermsService.new
        es.reposition
        expected = ('A'..'Z').to_a
        v = View.get_by_code('roman.popular')
        eng_alpha = Perspective.get_by_code('eng.alpha')
        sorted = Feature.current_roots_by_perspective(eng_alpha).collect{|f| f.prioritized_name(v).name }
        expect(sorted).to eq(expected)
      end
    end
  end
end


