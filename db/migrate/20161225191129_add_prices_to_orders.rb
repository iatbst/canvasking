class AddPricesToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :before_price, :decimal
    add_column :orders, :shipping_price, :decimal
    add_column :orders, :tax_price, :decimal
    add_column :orders, :total_price, :decimal
  end
end
