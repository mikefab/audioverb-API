class CreateActs < ActiveRecord::Migration[6.0]
  def change
    create_table :acts do |t|
      t.integer :user_id
      t.string :user_name
      t.integer :cap_id
      t.integer :num
      t.string :nam

      t.timestamps
    end
    add_index :acts, :user_id
    add_index :acts, :nam
  end
end
