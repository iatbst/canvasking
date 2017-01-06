class AddArtImageToItems < ActiveRecord::Migration
  def change
    add_column :items, :art_image, :string
    add_column :items, :art_model_id, :string
  end
end
