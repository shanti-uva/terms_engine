# == Schema Information
#
# Table name: definition_associations
#
#  id                       :bigint           not null, primary key
#  associated_type          :string           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  associated_id            :bigint           not null
#  definition_id            :bigint           not null
#  feature_relation_type_id :bigint           not null
#  perspective_id           :bigint
#
# Indexes
#
#  index_definition_associations_on_associated                (associated_type,associated_id)
#  index_definition_associations_on_definition_id             (definition_id)
#  index_definition_associations_on_feature_relation_type_id  (feature_relation_type_id)
#  index_definition_associations_on_perspective_id            (perspective_id)
#
# Foreign Keys
#
#  fk_rails_...  (definition_id => definitions.id)
#  fk_rails_...  (feature_relation_type_id => feature_relation_types.id)
#  fk_rails_...  (perspective_id => perspectives.id)
#
class DefinitionAssociation < ApplicationRecord
  belongs_to :definition, touch: true
  belongs_to :associated, polymorphic: true, touch: true
  belongs_to :perspective
  belongs_to :feature_relation_type
  
  def feature
    self.definition.feature
  end
end
