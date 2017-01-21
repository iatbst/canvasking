class AddColCloneOfToItems < ActiveRecord::Migration
  def change
    add_column :items, :clone_of, :integer
  end
end
