class CreateTenses < ActiveRecord::Migration[6.0]
  def change
    create_table :tenses do |t|
      t.string :tense
      t.integer :mood_id
      t.integer :tiempo_id
      t.integer :lng_id
      t.integer :priority

      t.timestamps
    end
    add_index :tenses, :tense
    add_index :tenses, :mood_id
    add_index :tenses, :tiempo_id
    add_index :tenses, :lng_id
    add_index :tenses, :priority
  end
end
