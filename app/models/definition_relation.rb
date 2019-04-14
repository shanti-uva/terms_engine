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
end
