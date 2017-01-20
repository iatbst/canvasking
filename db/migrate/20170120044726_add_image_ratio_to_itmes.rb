class AddImageRatioToItmes < ActiveRecord::Migration
  def change
    add_column :items, :image_h_w_ratio, :decimal
  end
end
