class AddPaddingToNam < ActiveRecord::Migration[6.0]
  def change
    add_column :nams, :pad_start, :string
    add_column :nams, :pad_end, :string
  end
end
