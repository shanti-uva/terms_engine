# == Schema Information
#
# Table name: passages
#
#  id           :bigint           not null, primary key
#  content      :text             not null
#  context_type :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  context_id   :integer          not null
#

require 'rails_helper'

RSpec.describe Passage, type: :model do
  context "when valid" do
    it "adds a passage to a FeatureName" do
      language = Language.get_by_code('eng')
      feature = Feature.create(fid: Feature.generate_pid)
      feature_name = feature.names.create(language: language, name: "TestName")
      if(feature_name.valid?)
        passage = feature_name.passages.create(content: "this is a passage")
      end
      expect(passage.content).to eq("this is a passage")
    end
  end
  context "when invalid" do
    it "doesn't accept empty passages" do
      language = Language.get_by_code('eng')
      feature = Feature.create(fid: Feature.generate_pid)
      feature_name = feature.names.create(language: language, name: "TestName")
      if(feature_name.valid?)
        passage = feature_name.passages.create(content: nil)
      end
      expect(passage.valid?).to eq(false)
    end
  end
end
