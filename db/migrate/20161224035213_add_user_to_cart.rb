class AddUserToCart < ActiveRecord::Migration
  def change
    add_reference :carts, :user, index: true
    add_foreign_key :carts, :users
  end
end
