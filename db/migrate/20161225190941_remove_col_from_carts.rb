class RemoveColFromCarts < ActiveRecord::Migration
  def change
    remove_column :carts, :before_price, :decimal
    remove_column :carts, :shipping_price, :decimal
    remove_column :carts, :tax_price, :decimal
    remove_column :carts, :total_price, :decimal
  end
end
