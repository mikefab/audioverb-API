class CreateTiempos < ActiveRecord::Migration[6.0]
  def change
    create_table :tiempos do |t|
      t.string :tiempo
      t.integer :lng_id
      t.integer :priority
    end
    add_index :tiempos, :tiempo
    add_index :tiempos, :lng_id
    add_index :tiempos, :priority
  end
end
