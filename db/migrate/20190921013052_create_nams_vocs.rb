class CreateNamsVocs < ActiveRecord::Migration[6.0]
  def change
    create_table :nams_vocs do |t|
      t.integer :nam_id
      t.integer :voc_id
    end
    add_index :nams_vocs, :nam_id
    add_index :nams_vocs, :voc_id
  end
end
