class CreateEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :entries do |t|
      t.integer :kanji_id
      t.string :entry
    end
    add_index :entries, :kanji_id
    add_index :entries, :entry
  end
end
