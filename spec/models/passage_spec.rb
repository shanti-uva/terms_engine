# == Schema Information
#
# Table name: passages
#
#  id           :bigint(8)        not null, primary key
#  context_id   :integer          not null
#  context_type :string           not null
#  content      :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe Passage, type: :model do
  context "when valid" do
    it "adds a passage to a definition" do
      language = Language.get_by_code('bod')
      term = Feature.create(fid: Feature.generate_pid)
      definition = term.definitions.create(language: language, content: "This is a test definition")
      if(definition.valid?)
        passage = definition.passages.create(content: "this is a passage")
      end
      expect(passage.content).to eq("this is a passage")
    end
  end
  context "when invalid" do
    it "doesn't accept empty passages" do
      language = Language.get_by_code('bod')
      term = Feature.create(fid: Feature.generate_pid)
      definition = term.definitions.create(language: language, content: "This is a test definition")
      if(definition.valid?)
        passage = definition.passages.create(content: nil)
      end
      expect(passage.valid?).to eq(false)
    end
  end
end
