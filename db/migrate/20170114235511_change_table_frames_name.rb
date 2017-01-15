class ChangeTableFramesName < ActiveRecord::Migration
  def change
    rename_table :table_frames, :frames
  end
end
