class CreateEtymologies < ActiveRecord::Migration[5.2]
  def change
    create_table :etymologies do |t|
      t.integer :context_id, null: false
      t.string :context_type, null: false
      t.text :content, null: false

      t.timestamps
    end
  end
end
