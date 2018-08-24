class CreateRecordings < ActiveRecord::Migration[5.1]
  def change
    create_table :recordings do |t|
      t.references :feature, foreign_key: true, null: false

      t.timestamps
    end
  end
end
