class AddImageOverviewTmpToItems < ActiveRecord::Migration
  def change
    add_column :items, :image_overview_tmp, :string
  end
end
