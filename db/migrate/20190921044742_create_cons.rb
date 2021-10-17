class CreateCons < ActiveRecord::Migration[6.0]
  def change
    create_table :cons do |t|
      t.string :con
      t.integer :tense_id
      t.integer :verb_id
      t.integer :mood_id
      t.integer :tiempo_id
      t.integer :lng_id
      t.integer :priority
      t.string :pronoun
    end
    add_index :cons, :con
    add_index :cons, :tense_id
    add_index :cons, :verb_id
    add_index :cons, :mood_id
    add_index :cons, :tiempo_id
    add_index :cons, :lng_id
    add_index :cons, :priority
  end
end
