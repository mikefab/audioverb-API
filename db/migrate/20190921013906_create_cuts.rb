class CreateCuts < ActiveRecord::Migration[6.0]
  def change
    create_table :cuts do |t|
      t.string :cap_id
      t.string :user_id, null: false
      t.string :start, null: false
      t.string :stop, null: false
      t.boolean :approved
      t.string :approved_by
      t.string :nam, null: false
      t.integer :num, null: false
      t.string  :user_name
      t.string :hashed_ip, null: false
      t.timestamps
    end
    add_index :cuts, :cap_id
    add_index :cuts, :user_id
    add_index :cuts, :nam
  end
end
