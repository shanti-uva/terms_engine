# == Schema Information
#
# Table name: etymologies
#
#  id           :bigint           not null, primary key
#  content      :text
#  context_type :string           not null
#  derivation   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  context_id   :integer          not null
#

require 'rails_helper'

RSpec.describe Etymology, type: :model do
  context "when valid" do
    it "creates etymology for term" do
      term = Feature.create(fid: Feature.generate_pid)
      etymology = term.etymologies.create(content: "A term etymology")
      expect(etymology.valid?).to eq(true)
    end
  end
end
