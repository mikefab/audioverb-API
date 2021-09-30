class CreateIdosNams < ActiveRecord::Migration[6.1]
  def change
    create_table :idos_nams do |t|
      t.integer :nam_id
      t.integer :ido_id
    end
    add_index :idos_nams, :nam_id
  end
end
