class AddPriceToCarts < ActiveRecord::Migration
  def change
    add_column :carts, :price, :decimal
  end
end
