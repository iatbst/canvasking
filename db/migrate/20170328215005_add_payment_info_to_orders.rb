class AddPaymentInfoToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :payment_info, :hstore, default: {}
  end
end
