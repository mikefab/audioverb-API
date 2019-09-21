class CreateCapsClas < ActiveRecord::Migration[6.0]
  def change
    create_table :caps_clas do |t|
      t.integer :cap_id
      t.integer :cla_id
    end
    add_index :caps_clas, :cap_id
    add_index :caps_clas, :cla_id
  end
end
