class AddDiscountPriceToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :discount_price, :decimal, precision: 30, scale: 2
  end
end
