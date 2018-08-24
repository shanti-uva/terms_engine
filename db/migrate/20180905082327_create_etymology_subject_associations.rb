class CreateEtymologySubjectAssociations < ActiveRecord::Migration[5.2]
  def change
    create_table :etymology_subject_associations do |t|
      t.references :etymology, foreign_key: true, null: false
      t.integer :subject_id, null: false
      t.integer :branch_id, null: false

      t.timestamps
    end
  end
end
