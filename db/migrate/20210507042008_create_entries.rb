class CreateEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :entries do |t|
      t.string :title
      t.string :url
      t.string :author
      t.text :content
      t.text :summary
      t.datetime :published
      t.string :guid
      t.belongs_to :feed, null: false, foreign_key: true

      t.timestamps
    end
  end
end
