class CreateLngsVocs < ActiveRecord::Migration[6.0]
  def change
    create_table :lngs_vocs do |t|
      t.integer :lng_id
      t.integer :voc_id
      t.integer :seen
      t.integer :olng_id
    end
    add_index :lngs_vocs, :lng_id
    add_index :lngs_vocs, :voc_id
    add_index :lngs_vocs, :olng_id
  end
end
