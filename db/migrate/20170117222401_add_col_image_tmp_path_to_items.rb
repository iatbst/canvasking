class AddColImageTmpPathToItems < ActiveRecord::Migration
  def change
    add_column :items, :image_tmp_paths, :hstore, default: {}
  end
end
