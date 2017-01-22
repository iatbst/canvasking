class AddItemReceivedAndRateToItems < ActiveRecord::Migration
  def change
    add_column :items, :received, :boolean, default: false
    add_column :items, :rate, :integer
  end
end
