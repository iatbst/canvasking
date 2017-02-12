class AddOrderRecvDateToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :order_recv_date, :datetime
  end
end
