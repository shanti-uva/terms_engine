class CreatePassageTranslations < ActiveRecord::Migration[5.2]
  def change
    create_table :passage_translations do |t|
      t.references :context, polymorphic: true, null: false
      t.text :content, null: false
      t.integer :language_id, null: false
      
      t.timestamps
    end
  end
end
