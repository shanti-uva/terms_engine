class AddDialectIdToRecording < ActiveRecord::Migration[5.1]
  def change
    add_column :recordings, :dialect_id, :integer
  end
end
