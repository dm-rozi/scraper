class CreateCachedPages < ActiveRecord::Migration[8.0]
  def change
    create_table :cached_pages do |t|
      t.string :url, null: false
      t.text :html_content
      t.datetime :fetched_at
      t.datetime :expires_at

      t.timestamps
    end
    add_index :cached_pages, :url, unique: true
  end
end
