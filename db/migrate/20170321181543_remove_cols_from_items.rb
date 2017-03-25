class RemoveColsFromItems < ActiveRecord::Migration
  def change
    remove_column :items, :depth
    remove_column :items, :border
    remove_column :items, :image_tmp
    remove_column :items, :image_overview_tmp
    remove_column :items, :clone_of
  end
end
