class CreateIdos < ActiveRecord::Migration[6.1]
  def change
    create_table :idos do |t|
      t.string :ido
      t.string :kind
      t.integer :lng_id


    end
    add_index :idos, :ido
    add_index :idos, :kind
    add_index :idos, :lng_id
  end
end
