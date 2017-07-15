class AddPlanToItems < ActiveRecord::Migration
  def change
    add_column :items, :plan, :integer
  end
end
