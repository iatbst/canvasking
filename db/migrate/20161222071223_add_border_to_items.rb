class AddBorderToItems < ActiveRecord::Migration
  def change
    add_column :items, :border, :string
  end
end
