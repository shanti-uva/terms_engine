class ChangeLanguageIdToNotNull < ActiveRecord::Migration[7.1]
  def change
    change_column_null :info_sources, :language_id, false
  end
end
