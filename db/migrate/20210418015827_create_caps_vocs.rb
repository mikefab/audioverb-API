class CreateCapsVocs < ActiveRecord::Migration[6.0]
  def change
    create_table :caps_vocs, :id => false do |t|
      t.integer :cap_id
      t.integer :voc_id
    end
    add_index :caps_vocs, :cap_id
    add_index :caps_vocs, :voc_id
  end
end
