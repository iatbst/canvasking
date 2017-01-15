class CreateTableFrames < ActiveRecord::Migration
  def change
    create_table :table_frames do |t|
      t.string :name
    end
  end
end
