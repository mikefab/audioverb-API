class CreateLasts < ActiveRecord::Migration[6.0]
  def change
    create_table :lasts do |t|
      t.integer :num
      t.string :kind
      t.string :bench

      t.timestamps
    end
  end
end
