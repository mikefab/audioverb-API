class CreateEntriesNams < ActiveRecord::Migration[6.1]
  def change
    create_table :entries_nams do |t|
      t.integer :nam_id
      t.integer :entry_id

      t.timestamps
    end
    add_index :entries_nams, :nam_id
    add_index :entries_nams, :entry_id
  end
end
