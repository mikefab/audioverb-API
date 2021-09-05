class CreateEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :entries do |t|
      t.integer :kanji_id
      t.string :entry
      t.string :pinyin
      t.boolean :is_idiom
    end
    add_index :entries, :kanji_id
    add_index :entries, :entry
    add_index :entries, :is_idiom
   # execute "ALTER TABLE entries CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;"
  end
end
