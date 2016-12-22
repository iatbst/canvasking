class AddDepthToItems < ActiveRecord::Migration
  def change
    add_column :items, :depth, :decimal
  end
end
