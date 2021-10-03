class CreatePassages < ActiveRecord::Migration[5.1]
  def change
    create_table :passages do |t|
      t.integer :context_id, null: false
      t.string :context_type, null: false
      t.text :content, null: false

      t.timestamps
    end
  end
end
