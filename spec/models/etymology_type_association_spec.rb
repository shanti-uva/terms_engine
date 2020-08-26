# == Schema Information
#
# Table name: etymology_subject_associations
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  branch_id    :integer          not null
#  etymology_id :bigint           not null
#  subject_id   :integer          not null
#
# Indexes
#
#  index_etymology_subject_associations_on_etymology_id  (etymology_id)
#
# Foreign Keys
#
#  fk_rails_...  (etymology_id => etymologies.id)
#

require 'rails_helper'

RSpec.describe EtymologyTypeAssociation, type: :model do
  context "when valid" do
    it "creates etymology_type_association for etymology" do
      term = Feature.create(fid: Feature.generate_pid)
      etymology = term.etymologies.create(content: "A term etymology")
      association_type = etymology.create_etymology_type_association(subject_id: 202)
      expect(association_type.valid? && !association_type.branch_id.nil?).to eq(true)
    end
  end
  context "when invalid" do
    it "doesn't allow empty subject_id" do
      term = Feature.create(fid: Feature.generate_pid)
      etymology = term.etymologies.create(content: "A term etymology")
      association_type = etymology.create_etymology_type_association(subject_id: nil)
      expect(association_type.valid?).to eq(false)
    end
  end
end
