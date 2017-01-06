class ChangeColFromItems < ActiveRecord::Migration
  def change
    rename_column :items, :art_image, :somatic_url
  end
end
