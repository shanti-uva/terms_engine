class CreateSentenceTranslations < ActiveRecord::Migration[7.1]
  def change
    create_table :sentence_translations do |t|
      t.text :content, null: false
      t.references :model_sentence, null: false, foreign_key: true
      t.integer :language_id, null: false

      t.timestamps
    end
  end
end
