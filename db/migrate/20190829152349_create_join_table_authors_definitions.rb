class CreateJoinTableAuthorsDefinitions < ActiveRecord::Migration[5.2]
  def change
    create_join_table :authors, :definitions do |t|
    end
  end
end
