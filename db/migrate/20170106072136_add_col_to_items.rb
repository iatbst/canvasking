class AddColToItems < ActiveRecord::Migration
  def change
    add_column :items, :art_filter, :boolean
    add_column :items, :art_image, :string
  end
end
