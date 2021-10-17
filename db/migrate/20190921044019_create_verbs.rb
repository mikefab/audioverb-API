class CreateVerbs < ActiveRecord::Migration[6.0]
  def change
    create_table :verbs do |t|
      t.string :verb
      t.integer :lng_id
    end
    add_index :verbs, :verb
    add_index :verbs, :lng_id
  end
end
