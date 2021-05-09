class AddDataToEntries < ActiveRecord::Migration[7.0]
  def change
    add_column :entries, :data, :text
  end
end
