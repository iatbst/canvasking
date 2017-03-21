class AddCanvasFrameToItems < ActiveRecord::Migration
  def change
    add_column :items, :canvas_frame, :string
  end
end
