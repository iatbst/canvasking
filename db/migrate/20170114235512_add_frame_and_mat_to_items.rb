class AddFrameAndMatToItems < ActiveRecord::Migration
  def change
    add_reference :items, :frame, index: true
    add_foreign_key :items, :frames
    add_column :items, :mat, :decimal
  end
end
