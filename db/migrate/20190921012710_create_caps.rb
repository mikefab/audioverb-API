class CreateCaps < ActiveRecord::Migration[6.0]
  def change
    create_table :caps do |t|
      t.string :cap
      t.integer :lng_id
      t.integer :num
      t.string :start
      t.string :stop
      t.integer :nam_id
      t.integer :src_id
      t.integer :wcount
      t.integer :ccount

      t.timestamps
    end
    add_index :caps, :cap
    add_index :caps, :lng_id
    add_index :caps, :num
    add_index :caps, :start
    add_index :caps, :nam_id
    add_index :caps, :src_id
  end
end
