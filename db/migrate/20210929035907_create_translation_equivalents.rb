class CreateTranslationEquivalents < ActiveRecord::Migration[5.2]
  def change
    create_table :translation_equivalents do |t|
      t.references :context, polymorphic: true, null: false
      t.string :content, null: false
      t.integer :language_id, null: false
      
      t.timestamps
    end
  end
end
