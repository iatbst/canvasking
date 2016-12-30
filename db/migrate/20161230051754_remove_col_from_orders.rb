class RemoveColFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :shipping_state
    remove_column :orders, :shipping_country
  end
end
