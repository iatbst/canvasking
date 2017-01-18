class AddColImageTmpToItems < ActiveRecord::Migration
  def change
    add_column :items, :image_tmp, :string
  end
end
