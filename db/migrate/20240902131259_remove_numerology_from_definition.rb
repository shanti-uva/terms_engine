class RemoveNumerologyFromDefinition < ActiveRecord::Migration[5.2]
  def change
    remove_column :definitions, :numerology
  end
end
