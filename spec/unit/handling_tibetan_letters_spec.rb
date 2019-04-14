require 'rails_helper'
require 'rake'
Rails.application.load_tasks

RSpec.describe TermsService do
  describe "Handling tibetan letters" do
    before(:all) do
      # Needed to populate languages, writing systems, etc.
      Rake::Task['kmaps_engine:db:seed'].invoke
      
      # Adding letters randomly in order to test sorting in DB
      r = Random.new
      ComplexScripts::TibetanLetter.all.sort_by{ |l| r.rand(100) }.each { |letter| TermsService.add_term(Feature::LETTER_SUBJECT_ID, letter.unicode, "#{letter.wylie}a") }
    end
    
    context "Sorting" do
      it "Sorts letters" do
        ts = TermsService.new
        expected = ComplexScripts::TibetanLetter.all.collect{|w| w[:unicode] }
        v = View.get_by_code('pri.tib.sec.roman')
        sorted = ts.sorted_terms.collect{|f| f.prioritized_name(v).name }
        expect(sorted).to eq(expected)
      end
      
      it "Updates position for letters" do
        ComplexScripts::TibetanLetter.all.each { |letter| TermsService.add_term(Feature::LETTER_SUBJECT_ID, letter.unicode, "#{letter.wylie}a") }
        ts = TermsService.new
        ts.reposition
        expected = ComplexScripts::TibetanLetter.all.collect{|w| w[:unicode] }
        v = View.get_by_code('pri.tib.sec.roman')
        sorted = Feature.roots.order('position').collect{|f| f.prioritized_name(v).name }
        expect(sorted).to eq(expected)
      end
    end
  end
end


