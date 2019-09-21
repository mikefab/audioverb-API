class CreateLngsNams < ActiveRecord::Migration[6.0]
  def change
    create_table :lngs_nams do |t|
      t.integer :lng_id
      t.integer :nam_id
    end
    add_index :lngs_nams, :lng_id
    add_index :lngs_nams, :nam_id
  end
end
