class AddBranchIdToFeatureRelationType < ActiveRecord::Migration[5.2]
  def up
    add_column :feature_relation_types, :branch_id, :integer, null: true
  end
  
  def down
    remove_column :feature_relation_types, :branch_id
  end
end
