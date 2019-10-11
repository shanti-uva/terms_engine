class CreateRelationSubjectAssociation < ActiveRecord::Migration[5.2]
  def change
    create_table :relation_subject_associations do |t|
      t.references :feature_relation, foreign_key: true, null: false
      t.integer :subject_id, null: false
      t.integer :branch_id, null: false
      t.timestamps
    end
  end
end
