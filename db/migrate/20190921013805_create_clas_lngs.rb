class CreateClasLngs < ActiveRecord::Migration[6.0]
  def change
    create_table :clas_lngs do |t|
      t.integer :cla_id
      t.integer :lng_id
      t.integer :o_lng

      t.timestamps
    end
    add_index :clas_lngs, :cla_id
    add_index :clas_lngs, :lng_id
    add_index :clas_lngs, :o_lng
  end
end
