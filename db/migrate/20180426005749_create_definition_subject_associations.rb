class CreateDefinitionSubjectAssociations < ActiveRecord::Migration[5.1]
  def change
    create_table :definition_subject_associations do |t|
      t.references :definition, foreign_key: true, null: false
      t.integer :subject_id, null: false
      t.integer :branch_id, null: false

      t.timestamps
    end
  end
end
