class CreateLngs < ActiveRecord::Migration[6.0]
  def change
    create_table :lngs do |t|
      t.string :lng
      t.string :cod

      t.timestamps
    end
  end
end
