# == Schema Information
#
# Table name: model_sentences
#
#  id           :bigint           not null, primary key
#  content      :text             not null
#  context_type :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  context_id   :integer          not null
#

require 'rails_helper'
require 'rake'

    # a model sentence should have a Model_sentence
    # language
    # language_type_id
    # sentence_type
    # source
    # spelling
    # major_dialect_family
    # major_dialect_family_type_id
    # specific_dialect
    # literary_genre
    # literary_genre_type_id
    # literary_period
    # literary_period_type_id
    # literary_form
    # literary_form_type_id
    # 
RSpec.describe ModelSentence, type: :model do
  before(:all) do
    Rake::Task['kmaps_engine:db:seed'].invoke
  end
  
  context "when valid" do
    it "adds model sentences to definition" do

      language = Language.get_by_code('bod')
      term = Feature.create(fid: Feature.generate_pid)
      definition = term.definitions.create(language: language, content: "This is a test definition")
      if(definition.valid?)
        sentence = definition.model_sentences.create(content: "this is a sentence")
      end
      expect(sentence.content).to eq("this is a sentence")
    end
  end
  context "when invalid" do
    it "doesn't accept empty sentences" do
      language = Language.get_by_code('bod')
      term = Feature.create(fid: Feature.generate_pid)
      definition = term.definitions.create(language: language, content: "This is a test definition")
      if(definition.valid?)
        sentence = definition.model_sentences.create(content: "")
      end
      expect(sentence.valid?).to eq(false)
    end
  end
end
