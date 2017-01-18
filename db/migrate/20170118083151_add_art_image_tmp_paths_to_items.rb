class AddArtImageTmpPathsToItems < ActiveRecord::Migration
  def change
    add_column :items, :art_image_tmp_paths, :hstore, default: {}
  end
end
