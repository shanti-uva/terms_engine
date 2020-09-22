class CreateDefinitionAssociations < ActiveRecord::Migration[5.2]
  def change
    create_table :definition_associations do |t|
      t.references :definition, foreign_key: true
      t.references :associated, polymorphic: true, index: { name: 'index_definition_associations_on_associated' }
      t.references :perspective, foreign_key: true
      t.references :feature_relation_type, foreign_key: true

      t.timestamps
    end
  end
end
