class AddCanvasDepthToItems < ActiveRecord::Migration
  def change
    add_column :items, :canvas_depth, :string
  end
end
