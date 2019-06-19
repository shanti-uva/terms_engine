# == Schema Information
#
# Table name: definition_relations
#
#  id             :bigint(8)        not null, primary key
#  child_node_id  :integer          not null
#  parent_node_id :integer          not null
#  ancestor_ids   :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class DefinitionRelation < ApplicationRecord
  acts_as_family_tree :tree, nil, node_class: 'Definition'
  
  has_many :imports, :as => 'item', :dependent => :destroy

  def self.search(filter_value)
    self.where(build_like_conditions(%W(children.content parents.content), filter_value)
    ).joins('LEFT JOIN definitions parents ON parents.id=definition_relations.parent_node_id LEFT JOIN definitions children ON children.id=definition_relations.child_node_id')
  end
end
