class CreateKanjis < ActiveRecord::Migration[6.1]
  def change
    create_table :kanjis do |t|
      t.string :kanji
      t.string :pinyin
    end
      add_index :kanjis, :kanji
      add_index :kanjis, :pinyin
  end
end
