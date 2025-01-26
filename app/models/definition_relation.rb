# == Schema Information
#
# Table name: definition_relations
#
#  id             :bigint           not null, primary key
#  ancestor_ids   :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  child_node_id  :integer          not null
#  parent_node_id :integer          not null
#

class DefinitionRelation < ApplicationRecord
  acts_as_family_tree :tree, nil, node_class: 'Definition'
  
  after_save do |record|
    [record.parent_node, record.child_node].each { |r| r.queued_update_hierarchy }
  end
  
  after_destroy do |record|
    [record.parent_node, record.child_node].each { |r| r.queued_update_hierarchy }
  end
  
  has_many :imports, :as => 'item', :dependent => :destroy

  def self.search(filter_value)
    self.where(build_like_conditions(%W(children.content parents.content), filter_value)
    ).joins('LEFT JOIN definitions parents ON parents.id=definition_relations.parent_node_id LEFT JOIN definitions children ON children.id=definition_relations.child_node_id')
  end
  
  def feature
    self.parent_node.feature
  end
end
