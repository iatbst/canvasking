class AddQuantityToCart < ActiveRecord::Migration
  def change
    add_column :carts, :quantity, :integer, :default => 0
  end
end
