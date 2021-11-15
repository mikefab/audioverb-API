class CreateNams < ActiveRecord::Migration[6.0]
  def change
    create_table :nams do |t|
      t.string :nam
      t.integer :lng_id
      t.string :duration
      t.integer :src_id
      t.string :season
      t.string :episode
      t.string :upldr
      t.string :title
      t.string :pad_start
      t.string :pad_end
    end
    add_index :nams, :nam
    add_index :nams, :lng_id
    add_index :nams, :src_id
    add_index :nams, :season
    add_index :nams, :episode
    add_index :nams, :upldr
    add_index :nams, :title
  end
end
