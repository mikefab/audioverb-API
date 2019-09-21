class CreateMoods < ActiveRecord::Migration[6.0]
  def change
    create_table :moods do |t|
      t.string :mood
      t.integer :lng_id
      t.integer :priority

      t.timestamps
    end
    add_index :moods, :mood
    add_index :moods, :lng_id
    add_index :moods, :priority
  end
end
