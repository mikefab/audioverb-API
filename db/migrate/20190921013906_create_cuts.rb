class CreateCuts < ActiveRecord::Migration[6.0]
  def change
    create_table :cuts do |t|
      t.integer :num
      t.string :start
      t.string :stop
      t.integer :cap_id

      t.timestamps
    end
    add_index :cuts, :num
    add_index :cuts, :start
    add_index :cuts, :cap_id
  end
end
