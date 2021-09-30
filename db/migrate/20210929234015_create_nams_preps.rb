class CreateNamsPreps < ActiveRecord::Migration[6.1]
  def change
    create_table :nams_preps do |t|
      t.integer :nam_id
      t.integer :prep_id
    end
    add_index :nams_preps, :nam_id
  end
end
