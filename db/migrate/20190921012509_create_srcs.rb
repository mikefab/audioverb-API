class CreateSrcs < ActiveRecord::Migration[6.0]
  def change
    create_table :srcs do |t|
      t.string :src
      t.integer :lng_id
      t.string :ser

      t.timestamps
    end
    add_index :srcs, :src
    add_index :srcs, :lng_id
    add_index :srcs, :ser
  end
end
