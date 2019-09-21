class CreateDefs < ActiveRecord::Migration[6.0]
  def change
    create_table :defs do |t|
      t.integer :kanji_id
      t.integer :entry_id
      t.text :def
      t.integer :voc_id
      t.integer :rank
      t.string :pos, limit: 10
      t.string :gram, limit: 10
      t.string :level, limit: 5
    end
    add_index :defs, :kanji_id
    add_index :defs, :entry_id
    add_index :defs, :def, :length => { :def => 5 }
    add_index :defs, :rank
    add_index :defs, :pos
    add_index :defs, :gram
    add_index :defs, :level
  end
end
