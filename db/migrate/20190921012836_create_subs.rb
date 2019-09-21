class CreateSubs < ActiveRecord::Migration[6.0]
  def change
    create_table :subs do |t|
      t.string :sub
      t.integer :cap_id
      t.integer :lng_id
      t.integer :num
      t.string :start
      t.string :stop
      t.integer :nam_id
      t.integer :src
      t.integer :clng_id

      t.timestamps
    end
    add_index :subs, :cap_id
    add_index :subs, :clng_id
  end
end
