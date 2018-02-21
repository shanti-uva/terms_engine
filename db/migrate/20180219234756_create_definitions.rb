class CreateDefinitions < ActiveRecord::Migration[5.1]
  def change
    create_table :definitions do |t|
      t.integer :feature_id, null: false
      t.integer :language_id, null: false
      t.boolean :is_public, null: false, default: false
      t.boolean :is_primary
      t.string :ancestor_ids
      t.integer :position, default: 0
      t.text :content, null: false
      t.integer :author_id
      t.integer :numerology
      t.string :tense

      t.timestamps
    end
  end
end
