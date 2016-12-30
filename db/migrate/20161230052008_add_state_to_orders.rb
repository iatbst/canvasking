class AddStateToOrders < ActiveRecord::Migration
  def change
    add_reference :orders, :state, index: true
    add_foreign_key :orders, :states
  end
end
