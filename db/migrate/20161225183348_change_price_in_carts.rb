class ChangePriceInCarts < ActiveRecord::Migration
  def change
    change_column :carts, :price, :decimal, :default => 0
  end
end
