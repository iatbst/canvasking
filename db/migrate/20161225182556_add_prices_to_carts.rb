class AddPricesToCarts < ActiveRecord::Migration
  def change
    add_column :carts, :before_price, :decimal
    add_column :carts, :shipping_price, :decimal
    add_column :carts, :tax_price, :decimal
    add_column :carts, :total_price, :decimal
  end
end
