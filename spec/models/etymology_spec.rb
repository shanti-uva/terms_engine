# == Schema Information
#
# Table name: etymologies
#
#  id           :bigint(8)        not null, primary key
#  context_id   :integer          not null
#  context_type :string           not null
#  content      :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
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
