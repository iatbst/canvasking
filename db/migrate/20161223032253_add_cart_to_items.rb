class AddCartToItems < ActiveRecord::Migration
  def change
    add_reference :items, :cart, index: true
    add_foreign_key :items, :carts
  end
end
