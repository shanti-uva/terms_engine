class CreateSubjectTermAssociations < ActiveRecord::Migration[5.1]
  def change
    create_table :subject_term_associations do |t|
      t.integer :feature_id, null: false
      t.integer :subject_id, null: false

      t.timestamps
    end
  end
end
