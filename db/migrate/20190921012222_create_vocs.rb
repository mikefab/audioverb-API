class CreateVocs < ActiveRecord::Migration[6.0]
  def change
    create_table :vocs do |t|
      t.string :voc
      t.float :freq
      t.integer :gram
      t.integer :lng_id
      t.integer :rank
      t.integer :raw
      t.integer :level
    end
    add_index :vocs, :level
  end
end
