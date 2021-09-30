class CreatePreps < ActiveRecord::Migration[6.1]
  def change
    create_table :preps do |t|
      t.string :prep
      t.integer :lng_id
    end
  end
end
