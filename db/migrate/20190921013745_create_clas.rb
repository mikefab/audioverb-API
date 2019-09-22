class CreateClas < ActiveRecord::Migration[6.0]
  def change
    create_table :clas do |t|
      t.string :cla
      t.integer :lng_id
      t.integer :mood_id
      t.integer :tense_id
      t.integer :tiempo_id
      t.integer :verb_id

      t.timestamps
    end
    add_index :clas, :cla
    add_index :clas, :lng_id
  end
end
