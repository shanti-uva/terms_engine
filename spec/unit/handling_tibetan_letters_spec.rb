require 'rails_helper'
require 'rake'
Rails.application.load_tasks

RSpec.describe TibetanTermsService do
  describe "Handling Tibetan letters" do
    before(:all) do
      # Needed to populate languages, writing systems, etc.
      Rake::Task['kmaps_engine:db:seed'].invoke
      
      # Needed to populate perspective
      Rake::Task['terms_engine:db:seed'].invoke
      # Adding letters randomly in order to test sorting in DB
      r = Random.new
      ComplexScripts::TibetanLetter.all.sort_by{ |l| r.rand(100) }.each { |letter| TibetanTermsService.add_term(level_subject_id: Feature::BOD_LETTER_SUBJECT_ID, tibetan: letter.unicode, wylie: "#{letter.wylie}a") }
    end
    
    context "Sorting" do
      it "Sorts letters" do
        ts = TibetanTermsService.new
        expected = ComplexScripts::TibetanLetter.all.collect{|w| w[:unicode] }
        v = View.get_by_code('pri.tib.sec.roman')
        sorted = ts.sorted_terms.collect{|f| f.prioritized_name(v).name }
        expect(sorted).to eq(expected)
      end
      
      it "Updates position for letters" do
        # TODO: check with Andres if this is needed, it is already being added in the before(:all)
        ComplexScripts::TibetanLetter.all.each { |letter| TibetanTermsService.add_term(level_subject_id: Feature::BOD_LETTER_SUBJECT_ID, tibetan: letter.unicode, wylie: "#{letter.wylie}a") }
        ts = TibetanTermsService.new
        ts.reposition
        expected = ComplexScripts::TibetanLetter.all.collect{|w| w[:unicode] }
        v = View.get_by_code('pri.tib.sec.roman')
        tib_alpha = Perspective.get_by_code('tib.alpha')
        sorted = Feature.current_roots_by_perspective(tib_alpha).collect{|f| f.prioritized_name(v).name }
        expect(sorted).to eq(expected)
      end
    end
  end
end


