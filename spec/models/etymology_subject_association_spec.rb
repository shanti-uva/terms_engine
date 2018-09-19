# == Schema Information
#
# Table name: etymology_subject_associations
#
#  id           :bigint(8)        not null, primary key
#  etymology_id :bigint(8)        not null
#  subject_id   :integer          not null
#  branch_id    :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe EtymologySubjectAssociation, type: :model do
  context "when valid" do
    it "creates etymology subject association for etymology" do
      term = Feature.create(fid: Feature.generate_pid)
      etymology = term.etymologies.create(content: "A term etymology")
      association = etymology.etymology_subject_associations.create(branch_id: 182, subject_id: 202)
      expect(association.valid?).to eq(true)
    end
  end

  context "when invalid" do
    it "doesn't accept empty branch id" do
      term = Feature.create(fid: Feature.generate_pid)
      etymology = term.etymologies.create(content: "A term etymology")
      association = etymology.etymology_subject_associations.create(branch_id: nil, subject_id: 202)
      expect(association.valid?).to eq(false)
    end
    it "doesn't accept empty subject id" do
      term = Feature.create(fid: Feature.generate_pid)
      etymology = term.etymologies.create(content: "A term etymology")
      association = etymology.etymology_subject_associations.create(branch_id: 182, subject_id: nil)
      expect(association.valid?).to eq(false)
    end
    pending "doesn't accept invalid branch id"
    pending "doesn't accept invalid subject id"
  end
  
end
