class RemoveShippingStateInOrders < ActiveRecord::Migration
  def remove
    remove_column :orders, :shipping_state
    remove_column :orders, :shipping_country
  end
end
